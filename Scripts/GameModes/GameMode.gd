# Serves both as the base class and standard run
class_name GameMode

var name = "Standard"
var description = "Default"
var border_color = Color("#b4cae1")
var block_color = Color(1.018, 1.018, 1.137)
var name_color = Color.WHITE
var win_level = 20 # The level after which you win.

var common_oops_chance = 0.2 # Chance of getting a pure chunk of sand/concrete/compressed
var legendary_oops_chance = 0.1 # Chance of getting a pure chunk of good stuff 

var prob_regular_size = 0.6 # Probability of piece size 4

func get_time(_level:int) -> float:
	return 90

func get_score(level:int) -> int:
	var levels = [200, 300, 500, 750]
	if level < levels.size():
		return levels[level]
	elif level < 8:
		return (level)*250
	else:
		# Increase goal quadratically from now on
		return 5*(level - 8)**2 + 250*(level - 1)


const common_oops_types: Array[Cell.Type] = [
	Cell.Type.Compressed,
	Cell.Type.Sand,
	Cell.Type.Concrete,
	Cell.Type.PlantPot,
]

const legendary_oops_types: Array[Cell.Type] = [
	Cell.Type.Multiplier,
	Cell.Type.Clock,
	Cell.Type.Lightning,
	Cell.Type.Mole,
	Cell.Type.Anvil,
]

const standard = Cell.Type.Standard

func rand() -> Cell.Type:
	return Cell.random_special_type()

func random_piece_size(level:int) -> int:
	# Size: We want a good chance of generating the nice size-4 pieces
	# And then we want more awkward sizes to become more common in the higher levels.
	var size = 4
	if randf() < prob_regular_size:
		return size
	
	size = randi_range(5, 8)
	if level >= 15:
		size = randi_range(5, 8)
	elif level >= 10:
		size = randi_range(4, 7)
	elif level >= 5:
		size = randi_range(4, 6)
	else:
		size = randi_range(4, 5)
	
	return size

func random_piece_types(level:int) -> Array[Cell.Type]:
	
	if randf() < common_oops_chance: # Chance of "OOPS! All X!" effect
		return [ common_oops_types.pick_random() ]
		
	if level >= 5 and randf() < legendary_oops_chance: # This is the good stuff
		return [ legendary_oops_types.pick_random() ]
	
	if level <= 10:
		if randf() <= 0.5:
			return [ standard, standard, rand(), rand() ]
		return [ standard, standard, standard, rand() ]
	elif level <= 15:
		if randf() <= 0.5:
			return [ standard, rand(), rand() ]
		return [ standard, standard, rand() ]
	elif level <= 20:
		if randf() <= 0.5:
			return [ standard, rand() ]
		var r = rand()
		return [ standard, r, r, rand() ]
	elif level <= 25:
		if randf() <= 0.5:
			return [ rand(), rand() ]
		var r = rand()
		return [ r, r, rand() ]
	else:
		if randf() <= 0.5:
			return [ rand(), rand(), rand(), rand() ]
		var r = rand()
		return [ r, r, r, rand() ]




var L = TetriminosTemplate.new([
		CellTemplate.new(-1, 0, Cell.Type.Standard),
		CellTemplate.new(0, 0, Cell.Type.Standard),
		CellTemplate.new(1, 0, Cell.Type.Standard),
		CellTemplate.new(-1, 1, Cell.Type.Standard),
	])
	
var J = TetriminosTemplate.new([
		CellTemplate.new(-1, 0, Cell.Type.Standard),
		CellTemplate.new(0, 0, Cell.Type.Standard),
		CellTemplate.new(1, 0, Cell.Type.Standard),
		CellTemplate.new(-1, -1, Cell.Type.Standard),
	])
	
var T = TetriminosTemplate.new([
		CellTemplate.new(1, 0, Cell.Type.Standard),
		CellTemplate.new(0, 0, Cell.Type.Standard),
		CellTemplate.new(-1, 0, Cell.Type.Standard),
		CellTemplate.new(0, 1, Cell.Type.Standard),
	])

var I = TetriminosTemplate.new([
		CellTemplate.new(1, 0, Cell.Type.Standard),
		CellTemplate.new(0, 0, Cell.Type.Standard),
		CellTemplate.new(-1, 0, Cell.Type.Standard),
		CellTemplate.new(-2, 0, Cell.Type.Standard),
	])

var S = TetriminosTemplate.new([
		CellTemplate.new(-1, -1, Cell.Type.Standard),
		CellTemplate.new(-1, 0, Cell.Type.Standard),
		CellTemplate.new(0, 0, Cell.Type.Standard),
		CellTemplate.new(0, 1, Cell.Type.Standard),
	])

var Z = TetriminosTemplate.new([
		CellTemplate.new(1, -1, Cell.Type.Standard),
		CellTemplate.new(1, 0, Cell.Type.Standard),
		CellTemplate.new(0, 0, Cell.Type.Standard),
		CellTemplate.new(0, 1, Cell.Type.Standard),
	])

var O = TetriminosTemplate.new([
		CellTemplate.new(0, 0, Cell.Type.Standard),
		CellTemplate.new(0, 1, Cell.Type.Standard),
		CellTemplate.new(1, 0, Cell.Type.Standard),
		CellTemplate.new(1, 1, Cell.Type.Standard),
	])

func get_starting_stash() -> Array[TetriminosTemplate]:
	return [ L, J, T, I, S, Z, O ]
