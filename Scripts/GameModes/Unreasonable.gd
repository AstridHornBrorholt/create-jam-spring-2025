extends GameMode
class_name Unreasonable

func _init():
	name = "Unreasonable"
	description = "Meant to be difficult"
	border_color = Color("f3a7ff")
	block_color = Color("ff50cb")
	name_color = Color("ff86ff")

func get_time(_level:int) -> float:
		return 70

	
func get_score(level:int) -> int:
	# I have no idea if this is doable. 
	var a = 1200
	var b = 1000
	var c = 288.8889 # Works out so level 20 is 1M 
	var d = 3
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
