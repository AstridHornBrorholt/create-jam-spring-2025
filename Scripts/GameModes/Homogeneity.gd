extends GameMode
class_name Homogeneity

func _init():
	name = "Homogeneity"
	description = "No mixed pieces"
	border_color = Color("d0ca8c")
	block_color = Color("f3f1da")
	name_color = Color("ffffadff")

func random_piece_types(_level:int) -> Array[Cell.Type]:
	return [rand()]
