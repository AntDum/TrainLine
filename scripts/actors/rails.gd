extends TileMapLayer
class_name Rails

@export var can_be_edited = true
const PARTICLE_DESTROY = preload("res://scenes/objects/particles/particle_destroy.tscn")
const PARTICLE_DESTROY_FIRE = preload("res://scenes/objects/particles/particle_destroy_fire.tscn")

@export var burning_delay : int = 1

@export var station_manager : StationManager

var rails_to_burn = []

var map_snapshot : PackedByteArray
	
func _started() -> void:
	can_be_edited = false
	map_snapshot = tile_map_data
	rails_to_burn.clear()

func _restart() -> void:
	can_be_edited = true
	tile_map_data = map_snapshot
	rails_to_burn.clear()

func get_tile_size() -> int:
	return tile_set.tile_size.x

func get_rail(global_coord : Vector2i) -> Rail:
	var map_coord = local_to_map(global_coord)
	return _get_rail_at(map_coord)

func _get_rail_at(coord: Vector2i) -> Rail:
	var data = get_cell_tile_data(coord)
	if station_manager and station_manager.registered.has(coord):
		var station = station_manager.registered[coord]
		return Rail.new(coord, data, station)
	else:
		return Rail.new(coord, data)

func _step(time: int) -> void:
	while not rails_to_burn.is_empty():
		var group = rails_to_burn[0]
		var rail_time = group[1]
		var rail_coord = group[0]
		
		if rail_time <= time:
			_add_particle_at(PARTICLE_DESTROY_FIRE, rail_coord)
			erase_cell(rail_coord)
			rails_to_burn.pop_front()
		else:
			break

func _clear() -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("clear"):
		_clear()

func _unhandled_input(event: InputEvent) -> void:
	if not can_be_edited: return
	if event is InputEventMouse:
		var is_pressed = false
		if event is InputEventMouseButton and event.is_pressed():
			is_pressed = true
		var mouse_coord = local_to_map(to_local(event.global_position))
		var rail = _get_rail_at(mouse_coord)
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT != 0:
			_set_rail_at(mouse_coord, rail, is_pressed)
		elif event.button_mask & MOUSE_BUTTON_MASK_RIGHT != 0:
			_remove_rail_at(mouse_coord, rail)
			

func _remove_rail_at(coord: Vector2i, rail: Rail) -> void:
	if not can_be_edited: return
	if rail.has_rail:
		if not rail.is_editable:
			return
		erase_cell(coord)
		EventBus.rail_removed.emit(coord)
		AudioManager.play_sound("remove")
		
		_add_particle_at(PARTICLE_DESTROY, coord)
		
		var neighboor_cells = get_surrounding_cells(coord)
		
		for cell in neighboor_cells:
			var neigh_rail = _get_rail_at(cell)
			if rail.has_rail and rail.is_editable:
				_update_rail_at(cell)
	
func _set_rail_at(coord: Vector2i, rail: Rail, is_pressed: bool) -> void:
	# Check that the rail can be edited
	if not can_be_edited: return
	if rail.has_rail && not rail.is_editable: return
	if station_manager.registered.has(coord): return
	
	var connect_to = { 0 : false, 1 : false, 2 : false, 3 : false }
	var to_update = []
	
	# Find the neighbor_cell where we can connect to
	for dir in [0, 1, 2, 3]:
		var cell_coord = get_neighbor_cell(coord, DirHelper.to_neighbor(dir))
		var neigh_rail = _get_rail_at(cell_coord)
		if not neigh_rail.has_rail: continue
		if neigh_rail.is_editable: # Always true but it's updatable
			connect_to[dir] = true
			to_update.append(cell_coord)
		elif neigh_rail.has_connection(DirHelper.invert_dir(dir)):
			connect_to[dir] = true
	
	
	var need_update : bool = true
	var rail_connect = RailHelper.get_rail_from_connection(connect_to)
	
	# Check for rail with 3 connection to flip them
	var current_rail = rail.get_rail_shape()
	if rail_connect | RailHelper.OPPOSITE == current_rail | RailHelper.OPPOSITE:
		var maybe = current_rail ^ RailHelper.OPPOSITE
		if RailHelper.editable_rail_atlas_coord.has(maybe) and is_pressed:
			need_update = false
			rail_connect = maybe
		
	# Fallback for error
	if rail_connect == 0:
		rail_connect = RailHelper.LR
	
	var new_rail = RailHelper.editable_rail_atlas_coord[rail_connect]
	
	# Shortcur if nothing new
	var rail_coord = get_cell_atlas_coords(coord)
	if rail_coord == new_rail:
		return
	
	# The real deal
	set_cell(coord, 0, new_rail)
	EventBus.rail_placed.emit(coord)
	AudioManager.play_sound("place")
	
	# Update except for flip of T rail
	if need_update:
		for cell_to_update in to_update:
			_update_rail_at(cell_to_update)

func burn_rail_from_global(pos: Vector2, time: int) -> void:
	var coord = local_to_map(to_local(pos))
	rails_to_burn.push_back([coord, time + burning_delay])	
	
func _add_particle_at(particle_type: PackedScene, coord: Vector2i) -> void:
	var particule = particle_type.instantiate()
	add_child(particule)
	particule.position = map_to_local(coord)

func _update_rail_at(coord: Vector2i) -> void:
	var rail = _get_rail_at(coord)
	if not rail.has_rail or not rail.is_editable: return
	
	# Check connection of neighboor cell
	var connect_to = { 0 : false, 1 : false, 2 : false, 3 : false }
	for dir in [0, 1, 2, 3]:
		var cell_coord = get_neighbor_cell(coord, DirHelper.to_neighbor(dir))
		var neigh_rail = _get_rail_at(cell_coord)
		if not neigh_rail.has_rail: continue
		elif neigh_rail.has_connection(DirHelper.invert_dir(dir)):
			connect_to[dir] = true
			
	var rail_connect = RailHelper.get_rail_from_connection(connect_to)
	if rail_connect == 0: # Destroy if alone
		erase_cell(coord)
	else:
		set_cell(coord, 0, RailHelper.editable_rail_atlas_coord[rail_connect])
	

func _enter_tree() -> void:
	EventBus.clear.connect(_clear)
	EventBus.start.connect(_started)
	EventBus.restart.connect(_restart)
	EventBus.step.connect(_step)

func _exit_tree() -> void:
	EventBus.clear.disconnect(_clear)
	EventBus.start.disconnect(_started)
	EventBus.restart.disconnect(_restart)
	EventBus.step.disconnect(_step)
	
