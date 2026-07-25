class_name TetriminoGenerator


static func generate_tetrimino(size:int, types:Array[Cell.Type]) -> TetriminosTemplate:		
	var cells:Array[Cell.Type] = []
	for __ in size:
		cells.append(types.pick_random())
	
	return random_piece(cells)

static func random_piece(cell_types:Array[Cell.Type]) -> TetriminosTemplate:
	var tetrimino: Array[CellTemplate] = []
	var possible_next_positions: Array[Vector2i] = [Vector2i(0, 0)]
	var used_positions: Array[Vector2i] = []
	var current_size: int = 0

	for next_type in cell_types:
		# Choose random next position
		var next_position = possible_next_positions[randi() % possible_next_positions.size()]
		possible_next_positions.erase(next_position)
		used_positions.append(next_position)
		
		current_size += 1

		# Add cell to tetrimino
		tetrimino.append(CellTemplate.new(next_position.x, next_position.y, next_type))

		# Add next position to possible next positions
		for offset in [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]:
			var new_position = next_position + offset
			if not possible_next_positions.has(new_position) and not used_positions.has(new_position):
				possible_next_positions.append(new_position)
	
	return TetriminosTemplate.new(tetrimino)
