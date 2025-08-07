extends RefCounted
class_name Rail

var coord : Vector2i

var station : BaseStation = null

var has_rail : bool = false
var dir_availables : PackedVector2Array = []
var is_editable : bool = true
var is_interactable : bool = false
var is_pickup : bool = false
var content : int = 0

func _init(coord: Vector2i, data: TileData = null, so : BaseStation = null) -> void:
	self.coord = coord
	if not data: return
	has_rail = true
	dir_availables = data.get_custom_data(&"from_to")
	is_editable = data.get_custom_data(&"editable")
	station = so

func is_station() -> bool:
	return station != null
	
func has_connection(dir: int) -> bool:
	for d in dir_availables:
		if d.x == dir or d.y == dir:
			return true
	return false

func get_rail_shape() -> int:
	var dir = 0
	var most = {}
	for d in dir_availables:
		dir |= int(2**d.x)
		dir |= int(2**d.y)
		most[d.y] = most.get_or_add(d.y, 0) + 1
	
	var twos = -1
	for key in most:
		if most[key] == 2:
			twos = key

	if twos != -1:
		match dir:
			RailHelper.LDR: # Base
				if twos == 1:
					dir |= RailHelper.OPPOSITE
			RailHelper.LUR: # Base
				if twos == 1:
					dir |= RailHelper.OPPOSITE
				
			RailHelper.URD: # Base
				if twos == 2:
					dir |= RailHelper.OPPOSITE
					
			RailHelper.ULD: # Base
				if twos == 2:
					dir |= RailHelper.OPPOSITE
	
	return dir

func will_go_to(from_dir: int) -> int:
	for d in dir_availables:
		if d.x == from_dir:
			return d.y
	return -1
