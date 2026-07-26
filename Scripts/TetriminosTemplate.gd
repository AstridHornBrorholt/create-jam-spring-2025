class_name TetriminosTemplate

var cells: Array[CellTemplate] = []

func _init(cells: Array[CellTemplate]) -> void:
	self.cells = cells
	canonize()

func is_empty() -> bool:
	return cells.size() == 0

func duplicate() -> TetriminosTemplate:
	return TetriminosTemplate.new(cells.duplicate(true))

func turn_into_type(type:Cell.Type) -> TetriminosTemplate:
	for i in len(cells):
		cells[i].type = type
	return self

func equals(other:TetriminosTemplate) -> bool:
	if self.cells.size() != other.cells.size():
		return false
	for cell in self.cells:
		var contains = false
		for cellʹ in other.cells:
			if cell.equals(cellʹ):
				contains = true
		if !contains:
			return false
	return true

# Get width of tetrimino
func get_width():
	var lower = 0
	var upper = 0
	for cell in cells:
		if cell.pos.x < lower:
			lower = cell.pos.x
		if cell.pos.x > upper:
			upper = cell.pos.x
	return upper - lower + 1
	
# Get height of tetrimino
func get_height():
	var lower = 0
	var upper = 0
	for cell in cells:
		if cell.pos.y < lower:
			lower = cell.pos.y
		if cell.pos.y > upper:
			upper = cell.pos.y
	return upper - lower + 1

func get_cell_types() -> Array[Cell.Type]:
	var result:Array[Cell.Type]
	for c in cells:
		result.append(c.type)
	return result

func get_shape_hash(cells) -> int:
	var _hash:int = 0
	for cell in cells:
		# Column-first 64bit encoding of the shape. Risk of collision beyond 8x8 pieces.
		_hash |= 1<<((cell.pos.y + 4) + 8*(cell.pos.x + 4))
	return _hash

# Canonize rotation and centering
func canonize():
	# Deep copy cause I think this was messing with an old ref
	var cs:Array[CellTemplate] = []
	for c in cells:
		cs.append(c.duplicate())
	center(cs)
	var min_hash = get_shape_hash(cs)
	var min_hash_cells:Array[CellTemplate] = []
	for c in cs:
		min_hash_cells.append(c.duplicate())
	for i in range(3):
		# Rotate cs
		for cell in cs:
			cell.pos = Vector2i(cell.pos.y, -cell.pos.x)
		center(cs)
		if get_shape_hash(cs) < min_hash:
			min_hash = get_shape_hash(cs)
			min_hash_cells = []
			for c in cs:
				min_hash_cells.append(c.duplicate())
	cells = min_hash_cells

func center(cs:Array[CellTemplate]):
	var min_corner = Vector2i()
	var max_corner = Vector2i()
	for c in cs:
		min_corner.x = min(min_corner.x, c.pos.x)
		min_corner.y = min(min_corner.y, c.pos.y)
		max_corner.x = max(max_corner.x, c.pos.x)
		max_corner.y = max(max_corner.y, c.pos.y)
	var adjust = min_corner + Vector2i(
		floor((max_corner.x - min_corner.x + 1) / 2),
		floor((max_corner.y - min_corner.y + 1) / 2)
	)
	for c in cs:
		c.pos -= adjust

func prettyprint():
	var result = ""
	var min_corner = Vector2i()
	var max_corner = Vector2i()
	for cell in cells:
		min_corner.x = min(min_corner.x, cell.pos.x)
		min_corner.y = min(min_corner.y, cell.pos.y)
		max_corner.x = max(max_corner.x, cell.pos.x)
		max_corner.y = max(max_corner.y, cell.pos.y)
	
	for y in range(min_corner.y - 1, max_corner.y + 1):
		for x in range(min_corner.x - 1, max_corner.x + 1): 
			var has_cell = false
			for cell in cells:
				has_cell = has_cell or cell.pos.x == x and cell.pos.y == y
			if has_cell:
				result += "▮"
			else:
					result += " "
		result += "\n"
	print(result)
