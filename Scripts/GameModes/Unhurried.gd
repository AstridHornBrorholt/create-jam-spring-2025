extends GameMode
class_name Unhurried

func _init():
	name = "Unhurried"
	description = "No time limit"
	border_color = Color("ff9d39")
	block_color = Color("ffd4a8")
	name_color = Color("fe9d00ff")

func get_time(_level:int) -> float:
	return INF

func random_piece_types(level:int) -> Array[Cell.Type]:
	var result = super.random_piece_types(level)
	for i in len(result):
		if result[i] == Cell.Type.Clock:
			result[i] = Cell.random_special_type()
	return result
