extends Object
class_name RailHelper



const editable_rail_atlas_coord : Dictionary = {
	U : Vector2i(0, 1),
	R : Vector2i(0, 2),
	D : Vector2i(0, 0),
	L : Vector2i(5, 2),
	LR : Vector2i(2, 3),
	UD : Vector2i(2, 0),
	DR : Vector2i(8, 0),
	DL : Vector2i(9, 0),
	UR : Vector2i(8, 1),
	UL : Vector2i(9, 1),
	RDL : Vector2i(6, 0),
	LDR : Vector2i(7, 0),
	RUL : Vector2i(6, 1),
	LUR : Vector2i(7, 1),
	URD : Vector2i(6, 3),
	DRU : Vector2i(6, 2),
	ULD : Vector2i(7, 3),
	DLU : Vector2i(7, 2),
	URDL : Vector2i(0, 4)
}

enum {
	U = 1, R = 2, D = 4, L = 8, # Single dir
	LR = 2 | 8, UD = 1 | 4, # Strait Double dir
	DR = 4 | 2, DL = 4 | 8, UR = 1 | 2, UL = 1 | 8, # Trun double dir
	RDL = 2 | 4 | 8 | 16, LDR = 8 | 4 | 2, RUL = 2 | 1 | 8 | 16, LUR = 8 | 1 | 2, # Triple (First is the direction of the turn
	DRU = 4 | 2 | 1 | 16, URD = 1 | 2 | 4, DLU = 4 | 8 | 1 | 16, ULD = 1 | 8 | 4, # Same
	URDL = 1 | 2 | 4 | 8, # Four dir
	OPPOSITE = 16, # Mask to inverte a triple connection
}

static func get_rail_from_connection(connection: Dictionary) -> int:
	var dir = 0
	
	for i in [0, 1, 2, 3]:
		if connection[i]:
			dir |= 2**i
	
	return dir
