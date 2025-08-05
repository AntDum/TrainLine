extends RefCounted
class_name Rail

var coord : Vector2i

var has_rail : bool = false
var dir_availables : PackedVector2Array = []
var is_editable : bool = true
var is_interactable : bool = false
var is_pickup : bool = false
var content : int = 0


func _init(coord: Vector2i, data: TileData = null) -> void:
	self.coord = coord
	if not data: return
	has_rail = true
	dir_availables = data.get_custom_data(&"from_to")
	is_editable = data.get_custom_data(&"editable")
	content = data.get_custom_data(&"content")
	is_interactable = content > 0
	is_pickup = data.get_custom_data(&"is_pickup")
	
func has_connection(dir: int) -> bool:
	for d in dir_availables:
		if d.x == dir or d.y == dir:
			return true
	return false

func get_rail_connection() -> int:
	var dir = 0
	for d in dir_availables:
		dir |= d.x
		dir |= d.y
	return dir

func will_go_to(from_dir: int) -> int:
	for d in dir_availables:
		if d.x == from_dir:
			return d.y
	return -1
