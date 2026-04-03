extends GameMode
class_name Challenge

func _init() -> void:
	name = "Challenge"
	description = "Challenging"
	border_color = Color("ff3225")
	name_color = Color("ff0000ff")
	common_oops_chance = 0.1
	legendary_oops_chance = 0.05
	prob_regular_size = 0.3

func get_time(_level:int) -> float:
	return 70

func get_score(level:int) -> int:
	var levels = [500, 750, 1500, 2000]
	if level < levels.size():
		return levels[level]
	elif level < 8:
		return (level)*500
	else:
		# Increase goal quadratically from now
		return 5*(level - 8)**2 + 500*(level - 1)
