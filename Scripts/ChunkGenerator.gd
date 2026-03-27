extends Node
class_name ChunkGenerator

const oops_types: Array[Cell.Type] = [
	Cell.Type.Compressed,
	Cell.Type.Multiplier,
	Cell.Type.Sand,
	Cell.Type.Concrete,
	Cell.Type.Clock,
	Cell.Type.PlantPot,
	Cell.Type.Lightning
]

const standard = Cell.Type.Standard

func rand() -> Cell.Type:
	return Cell.random_special_type()

func generate_chunk() -> Array[Cell.Type]:
	var level = CurrentRun.level
	
	if level >= 5 and randf() < 0.1: # Chance of "OOPS! All X!" effect, for X in oops_types
		return [ oops_types.pick_random() ]
	
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
