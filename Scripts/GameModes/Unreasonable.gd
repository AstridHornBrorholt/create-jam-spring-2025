extends GameMode
class_name Unreasonable

func _init():
	name = "Unreasonable"
	description = "Meant to be difficult"
	border_color = Color("f3a7ff")
	block_color = Color("ff50cb")
	name_color = Color("ff86ff")

func get_time(level:int) -> float:
		return 70

	
func get_score(level:int) -> int:
	return 5*(level)**2 + 1000*(level) + 1000
