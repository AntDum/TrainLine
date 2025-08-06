extends Rail
class_name Station

var station_manager : StationManager
var station_object : StationObject

func _init(coord: Vector2i, data: TileData) -> void:
	super(coord, data)
	station_manager = StationManager.instance
			
	station_object = station_manager.registered[coord]

func job_done() -> void:
	station_object.job_done()
