extends BaseStation
class_name SwitchLane

var rail : Rail
var shape : int

func _ready() -> void:
	super()
	rail = rails.get_rail(global_position)
	shape = rail.get_rail_shape()
	if len(rail.dir_availables) != 3:
		printerr("Only work on T rails")

func activate(_toggle: bool) -> void:
	shape ^= RailHelper.OPPOSITE
	
	var new_rail = RailHelper.editable_rail_atlas_coord[shape]
	
	# The real deal
	rails.set_cell(coord, 0, new_rail, 1)
