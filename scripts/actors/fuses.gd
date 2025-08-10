extends TileMapLayer
class_name Fuses

@export var station_manager : StationManager

const PARTICLE_DESTROY_FIRE = preload("res://scenes/objects/particles/particle_destroy_fire.tscn")

var map_snapshot : PackedByteArray

var to_burn = []

func _ready() -> void:
	map_snapshot = tile_map_data

func burn(coord: Vector2i) -> void:
	to_burn.append(coord)

func _burned(coord: Vector2i) -> void:
	if station_manager and station_manager.registered.has(coord):
		var station = station_manager.registered[coord]
		print(station)
		if station is BurnStation or station is ReplaceStation:
			station.burn()
	erase_cell(coord)
	_add_particle_at(PARTICLE_DESTROY_FIRE, coord)

func _restart() -> void:
	tile_map_data = map_snapshot
	to_burn.clear()

func _step(time: int) -> void:
	var next_step = []
	for coord in to_burn:
		if get_cell_source_id(coord) != -1:
			_burned(coord)
			for d in [0, 1, 2, 3]:
				var cell_coord = get_neighbor_cell(coord, DirHelper.to_neighbor(d))
				if get_cell_source_id(cell_coord) != -1:
					next_step.append(cell_coord)
	to_burn = next_step
		

func _add_particle_at(particle_type: PackedScene, coord: Vector2i) -> void:
	var particule = particle_type.instantiate()
	particule.position = map_to_local(coord)
	add_child(particule)


func _enter_tree() -> void:
	EventBus.restart.connect(_restart)
	EventBus.step.connect(_step)

func _exit_tree() -> void:
	EventBus.restart.disconnect(_restart)
	EventBus.step.disconnect(_step)
	
