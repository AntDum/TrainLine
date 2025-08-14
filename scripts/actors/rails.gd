@icon("res://assets/icons/node_2D/rail.png")
extends TileMapLayer
class_name Rails

@export var can_be_edited = true
const PARTICLE_DESTROY = preload("res://scenes/objects/particles/particle_destroy.tscn")
const PARTICLE_DESTROY_FIRE = preload("res://scenes/objects/particles/particle_destroy_fire.tscn")

@export var burning_delay : int = 1

@export var station_manager : StationManager
@export var fuses : Fuses

var rails_to_burn = []

var current_mode := ModeHelper.Mode.EDIT

var map_snapshot : PackedByteArray

@export var swap_cooldown : float = 0.2
var time_since_last_swap = {}

# Game events
func _started() -> void:
	can_be_edited = false
	map_snapshot = tile_map_data
	rails_to_burn.clear()

func _restart() -> void:
	can_be_edited = true
	tile_map_data = map_snapshot
	rails_to_burn.clear()

# Public utils
func get_tile_size() -> int:
	return tile_set.tile_size.x

func get_rail(global_pos : Vector2) -> Rail:
	var map_coord = local_to_map(global_pos)
	return _get_rail_at(map_coord)

func set_rail_at(coord: Vector2i) -> void:
	var prev = can_be_edited
	set_cell(coord, 0, Vector2i(0, 0))
	_set_rail_at(coord, _get_rail_at(coord), false, true)
	can_be_edited = prev

func burn_rail_from_global(pos: Vector2, time: int) -> void:
	var coord = local_to_map(to_local(pos))
	rails_to_burn.push_back([coord, time + burning_delay])	

# Private functions
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
			if fuses:
				fuses.burn(rail_coord)
		else:
			break

func _clear() -> void:
	if not can_be_edited: return
	for coord in get_used_cells():
		var rail = _get_rail_at(coord)
		if rail.is_editable:
			erase_cell(coord)
			_add_particle_at(PARTICLE_DESTROY, coord)

func _mode_changed(mode: ModeHelper.Mode) -> void:
	current_mode = mode

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("clear"):
		_clear()

func _unhandled_input(event: InputEvent) -> void:
	if not can_be_edited: return
	if event is InputEventMouse:
		_handle_mouse_event(event)

func _handle_mouse_event(event: InputEventMouse) -> void:
	var mouse_coord = local_to_map(to_local(event.global_position))
	var rail = _get_rail_at(mouse_coord)

	match event.button_mask:
		MOUSE_BUTTON_MASK_LEFT:
			match current_mode:
				ModeHelper.Mode.EDIT:
					_set_rail_at(mouse_coord, rail) # ADD
				ModeHelper.Mode.REMOVE:
					_remove_rail_at(mouse_coord, rail) # REMOVE
				ModeHelper.Mode.TOGGLE:
					_set_rail_at(mouse_coord, rail, true) # SWAP
		MOUSE_BUTTON_MASK_RIGHT:
			match current_mode:
				ModeHelper.Mode.EDIT:
					_remove_rail_at(mouse_coord, rail) # REMOVE
				ModeHelper.Mode.REMOVE:
					_set_rail_at(mouse_coord, rail) # ADD
				ModeHelper.Mode.TOGGLE:
					_set_rail_at(mouse_coord, rail, true) # SWAP
		MOUSE_BUTTON_MASK_MIDDLE:
			if event is InputEventMouseButton:
				_set_rail_at(mouse_coord, rail, true) # SWAP

# Rails placement
func _can_edit_rail(coord: Vector2i, rail: Rail, forced: bool = false) -> bool:
	return forced or (
		can_be_edited and 
		rail.is_editable and 
		not station_manager.registered.has(coord))

func _remove_rail_at(coord: Vector2i, rail: Rail) -> void:
	if not rail.has_rail or not _can_edit_rail(coord, rail):
		return

	erase_cell(coord)
	EventBus.rail_removed.emit(coord)
	AudioManager.play_sound("remove")
	
	_add_particle_at(PARTICLE_DESTROY, coord)
	
	for cell in get_surrounding_cells(coord):
		var neigh_rail = _get_rail_at(cell)
		if neigh_rail.has_rail and neigh_rail.is_editable:
			_update_rail_at(cell)
	
func _get_connection_data(coord: Vector2i, can_update: bool = true) -> Dictionary:
	var connect_to = {0: false, 1: false, 2: false, 3: false}
	var to_update = []
	
	for dir in [0, 1, 2, 3]:
		var neighbor_coord = get_neighbor_cell(coord, DirHelper.to_neighbor(dir))
		var neigh_rail = _get_rail_at(neighbor_coord)
		if not neigh_rail.has_rail:
			continue
		if neigh_rail.is_editable and can_update:
			connect_to[dir] = true
			to_update.append(neighbor_coord)
		elif neigh_rail.has_connection(DirHelper.invert_dir(dir)):
			connect_to[dir] = true

	
	return { "connect_to": connect_to, "to_update": to_update }

func _resolve_rail_connection(rail: Rail, conn_data: Dictionary, swap_mode: bool) -> int:
	var desired_rail = RailHelper.get_rail_from_connection(conn_data.connect_to)
	var current_rail = rail.get_rail_shape()
	
	# Fallback if no connections
	if desired_rail == 0:
		return -1 if swap_mode else RailHelper.LR

	var can_be_flipped = (desired_rail | RailHelper.OPPOSITE) == (current_rail | RailHelper.OPPOSITE)
	
	if can_be_flipped:
		if not swap_mode:
			return -1 # Flips only allowed in swap mode

		var opposite_rail = current_rail ^ RailHelper.OPPOSITE
		return opposite_rail if RailHelper.editable_rail_atlas_coord.has(opposite_rail) else -1
	
	# If swap mode, only flipping is allowed
	if swap_mode:
		return -1
	
	return desired_rail

func _place_rail(coord: Vector2i, new_rail: Vector2i) -> void:
	set_cell(coord, 0, new_rail)
	EventBus.rail_placed.emit(coord)
	AudioManager.play_sound("place")

func _set_rail_at(coord: Vector2i, rail: Rail, swap_mode: bool = false, forced: bool = false) -> void:
	# Check that the rail can be edited
	if not _can_edit_rail(coord, rail, forced):
		return

	if swap_mode:
		if time_since_last_swap.has(coord):
			if time_since_last_swap[coord] <= 0:
				time_since_last_swap.erase(coord)
			else:
				return
	
	var connection_data = _get_connection_data(coord)

	var rail_connect = _resolve_rail_connection(rail, connection_data, swap_mode)
	
	if rail_connect == -1:
		return

	var new_rail = RailHelper.editable_rail_atlas_coord[rail_connect]
	
	# Shortcut if nothing new
	if new_rail == get_cell_atlas_coords(coord):
		return
	
	# The real deal
	_place_rail(coord, new_rail)
	
	# Update except for flip of T rail
	if not swap_mode:
		for cell in connection_data.to_update:
			_update_rail_at(cell)
	else:
		time_since_last_swap[coord] = swap_cooldown

func _update_rail_at(coord: Vector2i) -> void:
	var rail = _get_rail_at(coord)
	if not rail.has_rail or not rail.is_editable: return
	
	# Check connection of neighboor cell
	var connection_data = _get_connection_data(coord, false)
			
	var rail_connect = RailHelper.get_rail_from_connection(connection_data.connect_to)
	if rail_connect == 0: # Destroy if alone
		erase_cell(coord)
	else:
		set_cell(coord, 0, RailHelper.editable_rail_atlas_coord[rail_connect])

func _process(delta: float) -> void:
	for coord in time_since_last_swap.keys():
		time_since_last_swap[coord] -= delta
		if time_since_last_swap[coord] <= 0:
			time_since_last_swap.erase(coord)
	
func _add_particle_at(particle_type: PackedScene, coord: Vector2i) -> void:
	var particule = particle_type.instantiate()
	particule.position = map_to_local(coord)
	add_child(particule)

func _enter_tree() -> void:
	EventBus.clear.connect(_clear)
	EventBus.start.connect(_started)
	EventBus.restart.connect(_restart)
	EventBus.step.connect(_step)
	EventBus.change_mode.connect(_mode_changed)

func _exit_tree() -> void:
	EventBus.clear.disconnect(_clear)
	EventBus.start.disconnect(_started)
	EventBus.restart.disconnect(_restart)
	EventBus.step.disconnect(_step)
	EventBus.change_mode.disconnect(_mode_changed)
	
