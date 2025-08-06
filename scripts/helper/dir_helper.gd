extends Object
class_name DirHelper

# 0 -> up
# 1 -> right
# 2 -> down
# 3 -> left

static func from_neighbor(neigh : TileSet.CellNeighbor) -> int:
	match neigh:
		TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_SIDE: return 0 
		TileSet.CellNeighbor.CELL_NEIGHBOR_RIGHT_SIDE: return 1
		TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_SIDE: return 2
		TileSet.CellNeighbor.CELL_NEIGHBOR_LEFT_SIDE: return 3
		_: return -1

static func to_neighbor(dir: int) -> TileSet.CellNeighbor:
	match dir:
		0: return TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_SIDE
		1: return TileSet.CellNeighbor.CELL_NEIGHBOR_RIGHT_SIDE
		2: return TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_SIDE
		3: return TileSet.CellNeighbor.CELL_NEIGHBOR_LEFT_SIDE
		_: return TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_SIDE

static func to_vector2(dir: int) -> Vector2i:
	match dir:
		0: return Vector2i.UP
		1: return Vector2i.RIGHT
		2: return Vector2i.DOWN
		3: return Vector2i.LEFT
		_: return Vector2i.ZERO

static func from_vector2(vec: Vector2i) -> int:
	match vec:
		Vector2i.UP: 	return 0
		Vector2i.RIGHT: return 1
		Vector2i.DOWN: 	return 2
		Vector2i.LEFT: 	return 3
		_: return -1
		
static func invert_dir(dir: int) -> int:
	return (dir + 2) % 4
