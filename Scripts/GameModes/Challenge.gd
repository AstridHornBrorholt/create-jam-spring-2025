extends GameMode
class_name Challenge

func _init() -> void:
	name = "Challenge"
	description = "Challenging"
	border_color = Color("ff3225")
	block_color = Color("ffb4ae")
	name_color = Color("ff0000ff")
	prob_regular_size = 0.3

func get_time(_level:int) -> float:
	return 70

func get_score(level:int) -> int:
	var a = 1000
	var b = 500
	var c = 353.335
	var d = 2
	var e = 10000
	var f = 10000
	var g = 1.55
	if level < 5:
		return a*level + b
	elif level <= win_level:
		# Increase goal quadratically from now on
		return a*(level) + b + c*(level - 5)**d
	else:
		# Add an exponential component. 
		return a*(level) + b + c*(level - 5)**d + e + f*g**(level - win_level)
