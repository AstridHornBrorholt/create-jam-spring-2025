extends GameMode
class_name Unreasonable

func _init():
	name = "Unreasonable"
	description = "Meant to be difficult"
	border_color = Color("f3a7ff")
	name_color = Color("ff86ffff")

func get_time(level:int) -> float:
	if level < 3:
		return 40
	else:
		return 70

	
func get_score(level:int) -> int:
	return 5*(level)**2 + 1000*(level) + 500
