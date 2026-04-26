extends TileMapLayer
class_name FillableBackground

var filledness:float = 0

func _get_tile_offset_from_score(score):
	return Vector2i(int(clampf(score * 5, 0, 5)), 0)

func set_filled(filledness: float):
	self.filledness = filledness
	for y in range(TetrisGame.HEIGHT):
		for x in range(TetrisGame.WIDTH):
			var a = float(y + 7) / (TetrisGame.HEIGHT + 7)
			var b = filledness
			var score = (a - b) * 3 + float((x ^ y) % 10) / 10
			set_cell(Vector2i(x, y), 0, _get_tile_offset_from_score(score))

func get_filled():
	return filledness
