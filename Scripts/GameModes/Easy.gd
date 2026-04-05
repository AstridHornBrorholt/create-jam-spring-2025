extends GameMode
class_name Easy

func _init() -> void:
	name = "Easy"
	description = "more lenient"
	border_color = Color("356fff")
	block_color = Color(0.54, 0.692, 1.2)
	name_color = Color("0000ffff")
	common_oops_chance = 0.1
	legendary_oops_chance = 0.05
	prob_regular_size = 0.3

func get_time(_level:int) -> float:
	return 120

func get_score(level:int) -> int:
	var levels = [500, 750, 1000]
	if level < levels.size():
		return levels[level]
	elif level < 8:
		return (level)*400
	else:
		# Increase goal quadratically from now
		return 2*(level - 8)**2 + 400*(level - 1)
