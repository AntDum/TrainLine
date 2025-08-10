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
	if is_destroyed: return
	rails.set_rail_at(coord)
	is_destroyed = true
	_hide_child()

func restore() -> void:
	if not is_destroyed: return
	rails.set_cell(coord, 0, rock_atlas_coord)
	is_destroyed = false
	_show_child()

func _restart() -> void:
	if is_destroyed:
		restore()

func _hide_child() -> void:
	for child in get_children():
		child.visible = false

func _show_child() -> void:
	for child in get_children():
		child.visible = true

func _enter_tree() -> void:
	EventBus.restart.connect(_restart)

func _exit_tree() -> void:
	EventBus.restart.disconnect(_restart)
