extends TileMapLayer
class_name Rails

@export var can_be_edited = true
const PARTICLE_DESTROY = preload("res://scenes/objects/particle_destroy.tscn")

func _enter_tree() -> void:
	EventBus.start.connect(_started)
	EventBus.restart.connect(_restart)

func _exit_tree() -> void:
	EventBus.start.disconnect(_started)
	EventBus.restart.disconnect(_restart)
	
func _started() -> void:
	can_be_edited = false

func _restart() -> void:
	can_be_edited = true

func get_tile_size() -> int:
	return tile_set.tile_size.x

func get_rail(global_coord : Vector2i) -> Rail:
	var map_coord = local_to_map(global_coord)
	return _get_rail_at(map_coord)

func _get_rail_at(coord: Vector2i) -> Rail:
	var data = get_cell_tile_data(coord)
	if data:
		if data.get_custom_data(&"content") != 0:
			return Station.new(coord, data)
		return Rail.new(coord, data)
	else:
		return Rail.new(coord)

func _unhandled_input(event: InputEvent) -> void:
	if not can_be_edited: return
	if event is InputEventMouse:
		var mouse_coord = local_to_map(to_local(event.global_position))
		var rail = _get_rail_at(mouse_coord)
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT != 0:
			_set_rail_at(mouse_coord, rail)
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
		
		
		var particule = PARTICLE_DESTROY.instantiate()
		add_child(particule)
		particule.position = map_to_local(coord)
		
		var neighboor_cells = get_surrounding_cells(coord)
		
		for cell in neighboor_cells:
			var neigh_rail = _get_rail_at(cell)
			if rail.has_rail and rail.is_editable:
				_update_rail_at(cell)
	
func _set_rail_at(coord: Vector2i, rail: Rail) -> void:
	if not can_be_edited: return
	if rail.has_rail && not rail.is_editable: return
	
	var connect_to = { 0 : false, 1 : false, 2 : false, 3 : false }
	var to_update = []
	
	for dir in [0, 1, 2, 3]:
		var cell_coord = get_neighbor_cell(coord, DirHelper.to_neighbor(dir))
		var neigh_rail = _get_rail_at(cell_coord)
		if not neigh_rail.has_rail: continue
		if neigh_rail.is_editable:
			connect_to[dir] = true
			to_update.append(cell_coord)
		elif neigh_rail.has_connection(DirHelper.invert_dir(dir)):
			connect_to[dir] = true
	
	var rail_connect = RailHelper.get_rail_from_connection(connect_to)
	if rail_connect == 0:
		rail_connect = RailHelper.LR
	
	var rail_coord = get_cell_atlas_coords(coord)
	var new_rail = RailHelper.editable_rail_atlas_coord[rail_connect]
	
	if rail_coord == new_rail:
		return
	
	set_cell(coord, 0, new_rail)
	EventBus.rail_placed.emit(coord)
	AudioManager.play_sound("place")
	
	for cell_to_update in to_update:
		_update_rail_at(cell_to_update)
	

func _update_rail_at(coord: Vector2i) -> void:
	var rail = _get_rail_at(coord)
	if not rail.has_rail or not rail.is_editable:
		return
	var connect_to = { 0 : false, 1 : false, 2 : false, 3 : false }
	for dir in [0, 1, 2, 3]:
		var cell_coord = get_neighbor_cell(coord, DirHelper.to_neighbor(dir))
		var neigh_rail = _get_rail_at(cell_coord)
		if not neigh_rail.has_rail: continue
		elif neigh_rail.has_connection(DirHelper.invert_dir(dir)):
			connect_to[dir] = true
	var rail_connect = RailHelper.get_rail_from_connection(connect_to)
	if rail_connect == 0:
		erase_cell(coord)
	else:
		set_cell(coord, 0, RailHelper.editable_rail_atlas_coord[rail_connect])
	
