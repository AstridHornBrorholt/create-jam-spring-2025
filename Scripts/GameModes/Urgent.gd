extends Unreasonable
class_name Urgent

func _init():
	name = "Urgent"
	description = "Very little time"
	border_color = Color("fdff7f")
	block_color = Color("ffffbd")
	name_color = Color("ffff00ff")

func get_starting_stash() -> Array[TetriminosTemplate]:
	var clock_face = O.duplicate()
	clock_face.cells[0].type = Cell.Type.Clock
	return [
		L,
		J,
		T,
		I,
		I,
		S.duplicate().turn_into_type(Cell.Type.Lightning),
		Z.duplicate().turn_into_type(Cell.Type.Lightning),
		clock_face
	]

func get_time(level:int) -> float:
	if level == 0:
		return 20
	else:
		return 40
