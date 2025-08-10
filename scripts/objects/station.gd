extends BaseStation
class_name Station

@export var contentValue : Gem.Type = Gem.Type.NO_GEM
## Need to put an item in it (For sign)
@export var put : bool = false
## Need to take an item from it (For box)
@export var take : bool = false
@export var waiting_time : int = 1

const PARTICLE_SUCCESS = preload("res://scenes/objects/particles/particle_success.tscn")

var satisfied : bool = false

func _init() -> void:
	is_on = true
	need_satisfaction = true

func accept_interaction() -> bool:
	return not satisfied

func accept_content(content: Gem.Type) -> bool:
	return content == contentValue

func get_content() -> Gem.Type:
	return contentValue

func can_put() -> bool:
	return put

func can_take() -> bool:
	return take

func interact() -> void:
	if satisfied: return
	super()
	satisfied = true
	station_manager.satisfied_station += 1
	
	_hide_child()
	_show_particle()

func time_to_wait() -> int:
	return waiting_time

func _show_particle() -> void:	
	var particle = PARTICLE_SUCCESS.instantiate()
	add_child(particle)
	particle.global_position = global_position


	
func _hide_child() -> void:
	for child in get_children():
		child.visible = false

func _show_child() -> void:
	for child in get_children():
		child.visible = true

func _restart() -> void:
	satisfied = false
	_show_child()

func _enter_tree() -> void:
	EventBus.restart.connect(_restart)

func _exit_tree() -> void:
	EventBus.restart.disconnect(_restart)
