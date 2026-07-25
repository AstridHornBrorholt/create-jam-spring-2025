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

func get_shape_hash() -> int:
	var _hash:int = 0
	for cell in cells:
		# Column-first 64bit encoding of the shape. Risk of collision beyond 8x8 pieces.
		_hash |= 1<<((cell.pos.y + 4) + 8*(cell.pos.x + 4))
	return _hash

func canonize():
	# Canonize rotation
	center()
	var min_hash = get_shape_hash()
	var min_hash_cells:Array[CellTemplate] = []
	for c in cells:
		min_hash_cells.append(c.duplicate())
	for i in range(3):
		# Rotate cells
		for cell in cells:
			cell.pos = Vector2i(cell.pos.y, -cell.pos.x)
		center()
		print("h: " + str(get_shape_hash()))
		if get_shape_hash() < min_hash:
			min_hash = get_shape_hash()
			min_hash_cells = []
			for c in cells:
				min_hash_cells.append(c.duplicate())
	print("m: " + str(min_hash))
	print("c: " + str(get_shape_hash()))
	cells = min_hash_cells
	print("c: " + str(get_shape_hash()))

func center():
	var min_corner = Vector2i()
	var max_corner = Vector2i()
	for cell in cells:
		min_corner.x = min(min_corner.x, cell.pos.x)
		min_corner.y = min(min_corner.y, cell.pos.y)
		max_corner.x = max(max_corner.x, cell.pos.x)
		max_corner.y = max(max_corner.y, cell.pos.y)
	var adjust = min_corner + Vector2i(
		floor((max_corner.x - min_corner.x + 1) / 2),
		floor((max_corner.y - min_corner.y + 1) / 2)
	)
	for cell in cells:
		cell.pos -= adjust
