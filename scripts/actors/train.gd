extends Node2D
class_name Train

enum ContentType {BOX, ROCK, EMPTY = -1}
	
@export var rails : Rails
@export var station_manager : StationManager

@export var speed : float = 1.5

@onready var sprite_2d: Sprite2D = $Sprite2D
var tile_size : int = 16

@export_range(0, 3, 1, "hide_slider") var dir : int = 1
@export var content : ContentType = ContentType.EMPTY
@export var contentValue : int = 0

enum Status {
	PROCESSING,
	FINISH_PROCESSING,
	RUNNING,
	WAITING,
}
var status : Status = Status.RUNNING

var delay : float = 0.05 # Will be sync

var start_dir : int
var start_pos : Vector2

var pos_target : Vector2

func _ready() -> void:
	tile_size = rails.get_tile_size()
	start_dir = dir
	start_pos = global_position
	pos_target = global_position
	
func _retry() -> void:
	dir = start_dir
	global_position = start_pos
	pos_target = start_pos
	status = Status.RUNNING
	contentValue = 0
	content = ContentType.EMPTY
	if not EventBus.step.is_connected(_step):
		EventBus.step.connect(_step)
	_set_sprite()

func _step(_time: int) -> void:
	AudioManager.play_sound("roll")
	match status:
		Status.PROCESSING:
			status = Status.FINISH_PROCESSING
		Status.FINISH_PROCESSING:
			status = Status.RUNNING
		
	var train_pos = rails.to_local(pos_target)
	var rail = rails.get_rail(train_pos)
	
	if rail.is_station():
		var station_object : StationObject = rail.station_object
		if status == Status.RUNNING:
			if station_object.satisfied:
				_crashed()
				return
			elif station_object.can_take and content == ContentType.EMPTY:
				contentValue = station_object.contentType
				content = ContentType.BOX
				status = Status.PROCESSING
				station_object.job_done()
			elif station_object.can_put and content == ContentType.BOX and station_object.contentType == contentValue:
				content = ContentType.EMPTY
				contentValue = 0
				status = Status.PROCESSING
				station_object.job_done()
			else:
				_crashed()
				return
	
	if status == Status.PROCESSING: return
	
	_move(rail)

	_set_sprite()

func _move(rail: Rail) -> void:
	var comming_from =  DirHelper.invert_dir(dir)
	var out_dir = rail.will_go_to(comming_from)
	
	if out_dir == -1:
		_crashed()
		return
	
	dir = out_dir
	pos_target = pos_target + Vector2(DirHelper.to_vector2(dir)) * tile_size
	
func _process(delta: float) -> void:
	global_position = lerp(global_position, pos_target, (1/delay) * delta * speed)
	
func _crashed() -> void:
	AudioManager.play_sound("crashed")
	print("OH NO !!")
	EventBus.step.disconnect(_step)
	EventBus.train_crashed.emit()
	
func _set_sprite() -> void:
	var dir_y : bool = dir == 0 or dir == 2
	match content:
		ContentType.ROCK:
			if dir_y:
				sprite_2d.frame = 3
			else:
				sprite_2d.frame = 1
		ContentType.BOX:
			if dir_y:
				sprite_2d.frame = 4
			else:
				sprite_2d.frame = 2
		_:
			if dir_y:
				sprite_2d.frame = 5
			else:
				sprite_2d.frame = 0

func _update_delay(del: float) -> void:
	delay = del

func _enter_tree() -> void:
	EventBus.step.connect(_step)
	EventBus.restart.connect(_retry)
	EventBus.delay_changed.connect(_update_delay)

func _exit_tree() -> void:
	EventBus.step.disconnect(_step)
	EventBus.restart.disconnect(_retry)
	EventBus.delay_changed.disconnect(_update_delay)
	AudioManager.stop_sound("roll")
