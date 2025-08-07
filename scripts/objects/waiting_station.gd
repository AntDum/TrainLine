extends BaseStation
class_name WaitingStationObject

@export var waiting_time : int = 10

func _init() -> void:
	is_on = true
	need_satisfaction = false

func time_to_wait() -> int:
	return waiting_time
