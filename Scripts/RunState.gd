extends Node2D
class_name RunState

# Script to contain player status such as level, lives, and tetrimino stash

var game_mode:GameMode = GameMode.new()

# The player's stash, minus all the ones that have already been put in play.
var current_stash: Array[TetriminosTemplate] = [];

var next_map:Array[Array] = MapSelector.get_empty().to_array()
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
var previously_held_position:Vector2 = Vector2.ZERO
var previously_next:TetriminosTemplate = TetriminosTemplate.new([])
var previously_next_position:Vector2 = Vector2.ZERO
var previously_falling:TetriminosTemplate = TetriminosTemplate.new([])
var previously_falling_position:Vector2 = Vector2.ZERO

# Used by the win screen. 
var game_grid:Array #Houses game.grid, the [x][y] array with all the cells in them. 
var game_background_filledness:float # The decaying background
var game_animated_background:Node2D # The "AnimatedBackground" with falling blocks

func _init() -> void:
	reset()

func reset():
	level = 0
	next_reward = LevelOption.RewardType.Create
	next_score_goal = get_level()[0]
	next_time_limit = get_level()[1]
	next_map = MapSelector.get_empty().to_array()
	stash = game_mode.get_starting_stash()
	accumulated_score = 0
	highest_score = 0
	previously_held = TetriminosTemplate.new([])
	previously_held_position = Vector2.ZERO
	previously_next = TetriminosTemplate.new([])
	previously_next_position = Vector2.ZERO
	previously_falling = TetriminosTemplate.new([])
	previously_falling_position = Vector2.ZERO

func set_game_mode(g:GameMode) -> void:
	game_mode = g
	reset()

func new_game():
	renew_stash_if_needed()

func renew_stash_if_needed():
	if current_stash.size() <= 0:
		current_stash = []
		for p in stash:
			current_stash.append(p.duplicate())
		current_stash.shuffle()
		
		if previously_held != null and !previously_held.is_empty():
			remove_from_curent_stash(previously_held)
		
		if previously_next != null and !previously_next.is_empty():
			remove_from_curent_stash(previously_next)

func pop_from_stash():
	renew_stash_if_needed()
	return current_stash.pop_back()

func remove_from_curent_stash(tetriminos:TetriminosTemplate):
	for i in current_stash.size():
		if current_stash[i].equals(tetriminos):
			current_stash.remove_at(i)
			return
	
	assert(false, "Failed to remove tetriminos because it does not apear to be in current_stash.")

func add_to_permanent_stash(tetriminos:TetriminosTemplate):
	stash.push_back(tetriminos)

func remove_from_permanent_stash(tetriminos:TetriminosTemplate):
	for i in stash.size():
		if stash[i].equals(tetriminos):
			stash.remove_at(i)
			return
	
	assert(false, "Failed to remove tetriminos because it does not apear to be in stash.")

func get_level(): # returns [score_goal, time_limit]
	return [game_mode.get_score(level), game_mode.get_time(level)]

func get_map() -> Array[Array]:
	return next_map

func increment_level():
	level += 1

func register_score(score):
	accumulated_score += score
	if score > highest_score:
		highest_score = score
