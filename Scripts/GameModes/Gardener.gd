extends Challenge
class_name Gardener

var plant_pot_chance = 0.3

func _init():
	name = "Gardener"
	description = "All about plants"
	border_color = Color("#4da980")
	name_color = Color("00ff00ff")

func get_starting_stash() -> Array[TetriminosTemplate]:
	return [ 
		L.duplicate().turn_into_type(Cell.Type.Plant),
		J.duplicate().turn_into_type(Cell.Type.Plant),
		T.duplicate().turn_into_type(Cell.Type.Plant),
		I.duplicate().turn_into_type(Cell.Type.Plant),
		I.duplicate().turn_into_type(Cell.Type.PlantPot),
		S.duplicate().turn_into_type(Cell.Type.Plant),
		Z.duplicate().turn_into_type(Cell.Type.Plant),
		O.duplicate().turn_into_type(Cell.Type.Sand)
	]

func random_piece_types(level:int) -> Array[Cell.Type]:
	if randf() < plant_pot_chance:
		return [Cell.Type.PlantPot]
	
	var conk_creet = super.random_piece_types(level)
	for i in len(conk_creet):
		if conk_creet[i] == Cell.Type.Standard:
			conk_creet[i] = Cell.Type.Plant
	return conk_creet
