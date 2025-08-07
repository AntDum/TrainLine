extends Marker2D
class_name BaseStation

@export var rails : Rails 

var station_manager : StationManager

var coord : Vector2i

var is_on : bool = false
var need_satisfaction : bool = false

func _ready() -> void:
	station_manager = StationManager.instance
	coord = rails.local_to_map(rails.to_local(global_position))
	
	station_manager.register(coord, self)

func accept_interaction() -> bool:
	return true

func interact() -> void:
	return

func time_to_wait() -> int:
	return 0
