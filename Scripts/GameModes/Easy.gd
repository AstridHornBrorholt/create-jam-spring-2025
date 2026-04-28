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
	var a = 150
	var b = 150
	var c = 12.85
	var d = 2
	var e = 2000
	var f = 200
	var g = 1.5
	if level < 8:
		return a*level + b
	elif level <= win_level:
		# Increase goal quadratically from now on
		return a*(level) + b + c*(level - 8)**d
	else:
		# Add an exponential component. 
		return a*(level) + b + c*(level - 8)**d + e + f*g**(level - win_level)
