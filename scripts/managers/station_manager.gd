extends Node
class_name StationManager

@export var rails : Rails

static var instance : StationManager

var registered : Dictionary = {}
var number_of_station = 0
var satisfied_station = 0 : set = _update_satis

func _ready() -> void:
	instance = self

func register(coord : Vector2i, station : BaseStation) -> void:
	if not registered.has(coord):
		registered[coord] = station
		if station.need_satisfaction:
			number_of_station = len(registered)
			EventBus.station_happy.emit(satisfied_station, number_of_station)
	
func _restart() -> void:
	satisfied_station = 0
	EventBus.station_happy.emit(satisfied_station, number_of_station)

func _update_satis(new_value: int) -> void:
	satisfied_station = new_value
	EventBus.station_happy.emit(satisfied_station, number_of_station)
	if satisfied_station == number_of_station:
		EventBus.all_station_satisfied.emit()
		AudioManager.play_sound("all_cleared")
	else:
		AudioManager.play_sound("station_cleared")
	
	
func _enter_tree() -> void:
	EventBus.restart.connect(_restart)

func _exit_tree() -> void:
	EventBus.restart.disconnect(_restart)
