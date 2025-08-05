extends Rail
class_name Station

class StationData:
	var satisfied : bool = false

var station_manager : StationManager
var station_data : StationData

func _init(coord: Vector2i, data: TileData) -> void:
	super(coord, data)
	station_manager = StationManager.instance
	
	if not station_manager.registered.has(coord):
		station_manager.registered[coord] = StationData.new()
		
	station_data = station_manager.registered[coord]

func job_done() -> void:
	if station_data.satisfied: return
	station_data.satisfied = true
	station_manager.satisfied_station += 1
