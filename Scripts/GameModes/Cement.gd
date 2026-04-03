extends Challenge
class_name Cement

var cement_chance = 0.3

func _init():
	name = "Cement"
	description = "Das conk creet babyee"
	border_color = Color("#646b84")
	name_color = Color("#a0a0a0")

func get_starting_stash():
	var creet:Array[TetriminosTemplate] = super.get_starting_stash()
	for conk:TetriminosTemplate in creet:
		for i in len(conk.cells):
			conk = conk.duplicate()
			conk.turn_into_type(Cell.Type.Concrete)
	return creet

func random_piece_types(level:int) -> Array[Cell.Type]:
	if randf() < cement_chance:
		return [Cell.Type.Concrete]
	
	var conk_creet = super.random_piece_types(level)
	for i in len(conk_creet):
		if conk_creet[i] == Cell.Type.Standard:
			conk_creet[i] = Cell.Type.ConcreteSemiBroken
	return conk_creet
