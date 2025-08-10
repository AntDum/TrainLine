extends BaseStation
class_name ReplaceStation

var rock_atlas_coord : Vector2i = Vector2i(6, 4)

var is_destroyed = true

func _ready() -> void:
	super()
	restore()

func burn() -> void:
	replace()

func replace() -> void:
	print("REPLACE", is_destroyed)
	if is_destroyed: return
	rails.set_rail_at(coord)
	is_destroyed = true

func restore() -> void:
	print("REPLACE", is_destroyed)
	if not is_destroyed: return
	rails.set_cell(coord, 0, rock_atlas_coord)
	is_destroyed = false

func _restart() -> void:
	if is_destroyed:
		restore()

func _enter_tree() -> void:
	EventBus.restart.connect(_restart)

func _exit_tree() -> void:
	EventBus.restart.disconnect(_restart)
