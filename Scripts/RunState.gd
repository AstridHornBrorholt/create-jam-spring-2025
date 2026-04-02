extends Node2D
class_name RunState

# Script to contain player status such as level, lives, and tetrimino stash


# The player's stash, minus all the ones that have already been put in play.
var current_stash: Array[TetriminosTemplate] = stash.duplicate();

var next_map:Array[Array] = MapSelector.get_random_map(1).to_array()
var next_score_goal = 100
var next_time_limit = 90
var next_reward:LevelOption.RewardType

# All the player's tetriminos. Hard-coded to starting values
var stash: Array[TetriminosTemplate] = []
var level: int = 0
var accumulated_score = 0
var highest_score = 0

# Keep track of the pieces that were previously in the "held" and "next" positions, and the falling one.
var previously_held:TetriminosTemplate = TetriminosTemplate.new([])
var previously_held_position:Vector2
var previously_next:TetriminosTemplate = TetriminosTemplate.new([])
var previously_next_position:Vector2
var previously_falling:TetriminosTemplate = TetriminosTemplate.new([])
var previously_falling_position:Vector2

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



func _init() -> void:
	reset()

func reset():
	level = 0
	next_reward = LevelOption.RewardType.Create
	next_score_goal = get_level()[0]
	next_time_limit = get_level()[1]
	# var tetrimino_generator = TetriminoGenerator.new()
	stash = [ L, J, T, I, S, Z, O ]
	accumulated_score = 0
	highest_score = 0
	previously_held = TetriminosTemplate.new([])
	previously_held_position = Vector2.ZERO
	previously_next = TetriminosTemplate.new([])
	previously_next_position = Vector2.ZERO
	previously_falling = TetriminosTemplate.new([])
	previously_falling_position = Vector2.ZERO

func new_game():
	current_stash = stash.duplicate()
	current_stash.shuffle()

func pop_from_stash():
	if current_stash.size() <= 0:
		current_stash = stash.duplicate()
		current_stash.shuffle()
	return current_stash.pop_back()

func peek_next():
	if current_stash.size() <= 0:
		current_stash = stash.duplicate()
		current_stash.shuffle()
	return current_stash.back()

func remove_from_curent_stash(tetriminos:TetriminosTemplate):
	for i in current_stash.size():
		if current_stash[i].equals(tetriminos):
			current_stash.remove_at(i)
			return
	
	assert(false, "Failed to remove tetriminos because it does not apear to be in current_stash.")

func remove_from_permanent_stash(tetriminos:TetriminosTemplate):
	for i in stash.size():
		if stash[i].equals(tetriminos):
			stash.remove_at(i)
			return
	
	assert(false, "Failed to remove tetriminos because it does not apear to be in stash.")



func get_level(): # returns [score_goal, time_limit]
	const levels = [
		[500, 90],
		[750, 90],
		[1500, 90],
		[2000, 90],
	]
	if level < levels.size():
		return levels[level]
	elif level < 8:
		return [(level)*500, 90]
	else:
		# Increase goal quadratically from now
		return [5*(level - 8)**2 + 500*(level - 1), 90]

func get_map() -> Array[Array]:
	return next_map

func increment_level():
	level += 1

func register_score(score):
	accumulated_score += score
	if score > highest_score:
		highest_score = score
