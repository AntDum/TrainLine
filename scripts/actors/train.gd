@icon("res://assets/icons/node_2D/locomotive.png")
extends Node2D
class_name Train

@export var rails : Rails

var station_manager : StationManager

@export_range(0, 3, 1, "hide_slider") var head_dir : int = 1
var head_pos : Vector2

var start_head_dir : int
var start_head_pos : Vector2

enum Status {
	CAN_INTERACT,
	FINISH_WAITING,
	WAITING,
	FREEZING
}

var tile_size : int = 16

var wagons : Array[Wagon] = []
var size : int
var items : int = 0

var status : Status = Status.CAN_INTERACT
var waiting_time = -1

var delay : float = 0.05 # Will be sync

func _ready() -> void:
	tile_size = rails.get_tile_size()
	station_manager = StationManager.instance
	for child in get_children():
		if child is Wagon:
			wagons.append(child)
	items = 0
	size = len(wagons)
	assert(size != 0, "Train need to have wagon as child")
		
	head_pos = wagons[0].global_position
	start_head_pos = head_pos
	start_head_dir = head_dir
	
	var tween_spawn = create_tween()
	for wagon in wagons:
		tween_spawn.tween_callback(wagon.spawn)
		tween_spawn.tween_interval(0.1)

func _restart() -> void:
	status = Status.CAN_INTERACT
	head_pos = start_head_pos
	head_dir = start_head_dir
	items = 0
	if not EventBus.step.is_connected(_step):
		EventBus.step.connect(_step)
	var tween_reset = create_tween()
	for wagon in wagons:
		tween_reset.tween_callback(wagon.reset)
		tween_reset.tween_interval(0.05)
	
func _step(time: int) -> void:
	if _contains(Gem.Type.BLUE):
		if status == Status.CAN_INTERACT:
			status = Status.FREEZING
			return
	
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
	
	AudioManager.play_sound("roll")
	
	var train_pos = rails.to_local(head_pos)
	var rail = rails.get_rail(train_pos)
	
	if status == Status.CAN_INTERACT:
		if rail.is_station():
			var station : BaseStation = rail.station
			if station.is_on:
				if not station.accept_interaction():
					_crashed("Nyaa ! You cannot go at this place twice")
					return
					
				if station is Station:
					if station.can_put():
						if not _is_empty() and _contains(station.get_content()):
							_remove(station.get_content())
						else:
							_crashed("Arg ! You didn't have the required gem")
							return
					
					if station.can_take():
						if not _is_full():
							_take_box(station.get_content())
						else:
							_crashed("Noo! Your cart is full")
							return
						
				
				if station is TeleportStation:
					if _contains(Gem.Type.PURPLE):
						_teleport(station.get_global_destination())
					else:
						_crashed("Did you forget ? You need the purple gem to teleport")
						return
					
				station.interact()
				waiting_time = station.time_to_wait()
				if waiting_time == 0:
					status = Status.FINISH_WAITING
				else:
					status = Status.WAITING
	
	if status == Status.WAITING: return
	
	var prev_pos = wagons[-1].pos_target
	
	_move(rail)

	if _contains(Gem.Type.RED):
		rails.burn_rail_from_global(prev_pos, time)

func _teleport(pos : Vector2) -> void:
	head_pos = pos
	wagons[0].need_to_teleport = true

func _move(rail: Rail) -> void:
	var comming_from =  DirHelper.invert_dir(head_dir)
	var out_dir = rail.will_go_to(comming_from)
	
	if out_dir == -1:
		_crashed("Aaahh ! There are no rail for your cart")
		return
	
	head_dir = out_dir
	head_pos = head_pos + Vector2(DirHelper.to_vector2(head_dir)) * tile_size
	
	var temp_delay = delay
	if  _contains(Gem.Type.BLUE):
		temp_delay *= 2 
		
	var next_pos = head_pos
	var next_dir = head_dir
	var need_tp = wagons[0].need_to_teleport
	for wagon in wagons:
		var tempos = wagon.pos_target
		var tempir = wagon.dir
		var temp_tp = wagon.needed_to_teleport
		wagon.need_to_teleport = need_tp
		wagon.move(next_pos, next_dir, temp_delay)
		need_tp = temp_tp
		next_pos = tempos
		next_dir = tempir
		
func _remove(gem : Gem.Type) -> void:
	if gem == Gem.Type.WHITE:
		head_dir = DirHelper.invert_dir(head_dir)
		wagons.reverse()
		head_pos = wagons[0].pos_target
		EventBus.flip_reality.emit()
		AudioManager.play_sound("mirrored")
	
	items -= 1
		
	for i in range(wagons.size()-1, -1, -1):
		var wagon = wagons[i]
		if wagon.contains(gem):
			wagon.clear()
			break
	
func _take_box(gem: Gem.Type) -> void:
	if gem == Gem.Type.WHITE:
		head_dir = DirHelper.invert_dir(head_dir)
		wagons.reverse()
		head_pos = wagons[0].pos_target
		EventBus.flip_reality.emit()
		AudioManager.play_sound("mirrored")
		
	items += 1
	
	for wagon in wagons: 
		if wagon.is_empty():
			wagon.take_box(gem)
			break

func _clear() -> void:
	for wagon in wagons:
		wagon.clear()

func _is_full() -> bool:
	return size <= items

func _is_empty() -> bool:
	return items == 0

func _contains(gem : Gem.Type) -> bool:
	for wagon in wagons:
		if wagon.contains(gem):
			return true
	return false

func _crashed(reason: String) -> void:
	if EventBus.step.is_connected(_step):
		EventBus.step.disconnect(_step)
	AudioManager.play_sound("crashed")
	print("Crashed because : ", reason)
	EventBus.train_crashed.emit(reason)
	
	for wagon in wagons:
		wagon.crashed()
	
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
