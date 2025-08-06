extends Node2D
class_name StationObject

@export var rails : Rails 
@export var contentType : int = 0
@export var can_put : bool = false
@export var can_take : bool = false

const PARTICLE_SUCCESS = preload("res://scenes/objects/particle_success.tscn")

var station_manager : StationManager

var coord : Vector2i

var satisfied : bool = false

func _ready() -> void:
	station_manager = StationManager.instance
	coord = rails.local_to_map(rails.to_local(global_position))
	
	if not station_manager.registered.has(coord):
		station_manager.registered[coord] = self

func job_done() -> void:
	if satisfied: return
	satisfied = true
	station_manager.satisfied_station += 1
	
	var particle = PARTICLE_SUCCESS.instantiate()
	add_child(particle)
	particle.global_position = global_position

func _restart() -> void:
	satisfied = false

func _enter_tree() -> void:
	EventBus.restart.connect(_restart)

func _exit_tree() -> void:
	EventBus.restart.disconnect(_restart)
