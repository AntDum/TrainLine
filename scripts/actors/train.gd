extends Node2D
class_name Train

enum ContentType {BOX, ROCK, EMPTY = -1}
	
@export var rails : Rails
@export var station_manager : StationManager

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var crash_particle: CPUParticles2D = $CrashParticle

var tile_size : int = 16

@export_range(0, 3, 1, "hide_slider") var dir : int = 1
@export var content_type : ContentType = ContentType.EMPTY
@export var gem_type : Gem.Type = Gem.Type.NO_GEM

var tween_pos : Tween

enum Status {
	CAN_INTERACT,
	FINISH_WAITING,
	WAITING,
	FREEZING
}

var status : Status = Status.CAN_INTERACT
var waiting_time = -1

@export var delay : float = 0.05 # Will be sync

var start_dir : int
var start_pos : Vector2

var pos_target : Vector2 # The actual position use for calculation
						# the global_pos is behind as it is currently in a animation

func _ready() -> void:
	tile_size = rails.get_tile_size()
	start_dir = dir
	start_pos = global_position
	pos_target = global_position
	
func _restart() -> void:
	crash_particle.emitting = false
	dir = start_dir
	if tween_pos:
		tween_pos.kill()
	global_position = start_pos
	pos_target = start_pos
	status = Status.CAN_INTERACT
	gem_type = Gem.Type.NO_GEM
	content_type = ContentType.EMPTY
	
	if not EventBus.step.is_connected(_step):
		EventBus.step.connect(_step)
	_set_sprite()

func _step(time: int) -> void:
	
	if gem_type == Gem.Type.BLUE:
		if status == Status.CAN_INTERACT:
			status = Status.FREEZING
			return
	
	AudioManager.play_sound("roll")
	
	match status:
		Status.FINISH_WAITING:
			status = Status.CAN_INTERACT
		Status.WAITING:
			if waiting_time <= 0:
				status = Status.FINISH_WAITING
			else:
				waiting_time -= 1
				return
		Status.FREEZING:
			status = Status.CAN_INTERACT
		
	var train_pos = rails.to_local(pos_target)
	var rail = rails.get_rail(train_pos)
	
	if status == Status.CAN_INTERACT:
		if rail.is_station():
			var station : BaseStation = rail.station
			if station.is_on:
				if not station.accept_interaction():
					_crashed()
					return
					
				if station is Station:
					if station.can_put() and not _is_empty() and station.accept_content(gem_type):
						_clear()
					elif station.can_take() and _is_empty():
						_take_box(station.get_content())
					else:
						_crashed()
						return
				
				if station is TeleportStation:
					if gem_type == Gem.Type.PURPLE:
						var global_dest_pos = station.get_global_destionation()
						if tween_pos:
							tween_pos.kill()
						global_position = global_dest_pos
						pos_target = global_dest_pos
					else:
						_crashed()
						return
					
				station.interact()
				status = Status.WAITING
				waiting_time = station.time_to_wait()
				
	
	if status == Status.WAITING: return
	
	var prev_pos = pos_target
	
	_move(rail)
	
	if gem_type == Gem.Type.RED:
		rails.burn_rail_from_global(prev_pos, time)	

	_set_sprite()

func _move(rail: Rail) -> void:
	var comming_from =  DirHelper.invert_dir(dir)
	var out_dir = rail.will_go_to(comming_from)
	
	if out_dir == -1:
		_crashed()
		return
	
	dir = out_dir
	pos_target = pos_target + Vector2(DirHelper.to_vector2(dir)) * tile_size
	if tween_pos:
		tween_pos.kill()
	
	tween_pos = create_tween()

	var temp_delay = delay
	if gem_type == Gem.Type.BLUE:
		temp_delay *= 2 
	tween_pos.tween_property(self, "global_position", pos_target, temp_delay)
	
	
func _crashed() -> void:
	crash_particle.emitting = true
	AudioManager.play_sound("crashed")
	print("OH NO !!")
	EventBus.step.disconnect(_step)
	EventBus.train_crashed.emit()

func _clear() -> void:
	if gem_type == Gem.Type.WHITE:
		dir = DirHelper.invert_dir(dir)
	
	content_type = ContentType.EMPTY
	gem_type = -1

func _take_box(gem: Gem.Type) -> void:
	gem_type = gem
	content_type = ContentType.BOX
	
	if gem == Gem.Type.WHITE:
		dir = DirHelper.invert_dir(dir)
		

func _is_empty() -> bool:
	return content_type == ContentType.EMPTY

func _set_sprite() -> void:
	var dir_y : bool = dir == 0 or dir == 2
	match content_type:
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
	EventBus.restart.connect(_restart)
	EventBus.delay_changed.connect(_update_delay)

func _exit_tree() -> void:
	EventBus.step.disconnect(_step)
	EventBus.restart.disconnect(_restart)
	EventBus.delay_changed.disconnect(_update_delay)
	AudioManager.stop_sound("roll")
