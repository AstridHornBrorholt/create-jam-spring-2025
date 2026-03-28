extends Node
class_name ChunkGenerator

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
	Cell.Type.Lightning,
]

const standard = Cell.Type.Standard

func rand() -> Cell.Type:
	return Cell.random_special_type()

func generate_chunk() -> Array[Cell.Type]:
	var level = CurrentRun.level
	
	if randf() < 0.2: # Chance of "OOPS! All X!" effect
		return [ common_oops_types.pick_random() ]
		
	if level >= 5 and randf() < 0.05: # This is the good stuff
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
