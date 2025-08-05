extends Node
class_name StationManager

@export var rails : Rails

static var instance : StationManager

var registered : Dictionary = {}
var number_of_station = 0
var satisfied_station = 0 : set = _update_satis

func _ready() -> void:
	instance = self
	_get_station()
	EventBus.station_happy.emit(satisfied_station, number_of_station)
	
func _retry() -> void:
	satisfied_station = 0
	for val in registered.values():
		val.satisfied = false
	EventBus.station_happy.emit(satisfied_station, number_of_station)

func _update_satis(new_value: int) -> void:
	satisfied_station = new_value
	EventBus.station_happy.emit(satisfied_station, number_of_station)
	if satisfied_station == number_of_station:
		EventBus.all_station_satisfied.emit()
		AudioManager.play_sound("all_cleared")
	else:
		AudioManager.play_sound("station_cleared")

func _get_station() -> void:
	var stations = []
	for base in [Vector2i(1, 2), Vector2i(5, 0), Vector2i(2, 2), Vector2i(5, 1)]:
		for alt in [1, 2, 3]:
			stations.append_array(rails.get_used_cells_by_id(0, base, alt))
	for station in stations:
		rails.get_rail(station)
	number_of_station = len(stations)
	
	
func _enter_tree() -> void:
	EventBus.restart.connect(_retry)
