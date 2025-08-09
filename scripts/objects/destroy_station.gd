extends BaseStation
class_name DestroyStation

@export var is_destroyed : bool = false

var start_is_destroyed : bool

var atlas_coord : Vector2i
var alternative_idx : int

func _ready() -> void:
	super()
	start_is_destroyed = is_destroyed
	atlas_coord = rails.get_cell_atlas_coords(coord)
	alternative_idx = rails.get_cell_alternative_tile(coord)
	if is_destroyed:
		is_destroyed = false
		destroy()

func destroy() -> void:
	if is_destroyed: return
	rails.erase_cell(coord)
	is_destroyed = true

func restore() -> void:
	if not is_destroyed: return
	rails.set_cell(coord, 0, atlas_coord, alternative_idx)
	is_destroyed = false

func toggle() -> void:
	if not is_destroyed:
		destroy()
	else:
		restore()

func set_state(destroyed: bool, flipped : bool = false) -> void:
	if flipped:
		destroyed = not destroyed
	if destroyed == is_destroyed:
		return
	if destroyed:
		destroy()
	else:
		restore()

func _restart() -> void:
	if start_is_destroyed == is_destroyed:
		return
	if start_is_destroyed:
		destroy()
	else:
		restore()

func _enter_tree() -> void:
	EventBus.restart.connect(_restart)

func _exit_tree() -> void:
	EventBus.restart.disconnect(_restart)
