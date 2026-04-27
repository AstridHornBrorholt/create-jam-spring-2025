extends Node2D
class_name WinScreen

const cell_prefab: PackedScene = preload("res://Prefabs/Cell.tscn")
const solitaire_effect_prefab: PackedScene = preload("res://Prefabs/SolitaireEffect.tscn")
@onready var game_grid = $"GameGrid"
@onready var win_sound = $"Sounds/NextLevel"
@onready var background = $"GameGrid/background"

var win_sound_repetitions = 2

var grid:Array
var cells:Array[Cell]

func _ready() -> void:
	win_sound.play()
	background.set_filled(CurrentRun.game_background_filledness)
	
	add_child(CurrentRun.game_animated_background)
	
	for row in TetrisGame.HEIGHT:
		var r = []
		grid.append(r)
		for col in range(TetrisGame.WIDTH):
			r.append(null)
	
	if len(CurrentRun.game_grid) > 0:
		for row in TetrisGame.HEIGHT:
			for col in TetrisGame.WIDTH:
				var cell = CurrentRun.game_grid[row][col]
				if cell == null:
					continue
				
				cells.append(set_at(col, row, cell))
	
	cells.shuffle()
	pop_next_cell()

func _process(_delta: float) -> void:
	if win_sound_repetitions > 0 and !win_sound.playing:
		win_sound.pitch_scale += 0.2
		win_sound.play()
		win_sound_repetitions -= 1

func set_at(x: int, y: int, type: Cell.Type) -> Cell:
	var cell = cell_prefab.instantiate()
	game_grid.add_child(cell)
	cell.position = Vector2i(x * TetrisGame.CELL_SIZE, y * TetrisGame.CELL_SIZE)
	cell.grid_pos = Vector2i(x, y)
	cell.type = type
	grid[y][x] = cell
	return cell

func pop_next_cell():
	if len(cells) == 0:
		return
	var c = cells.pop_back()
	
	var sol:SolitaireEffect = solitaire_effect_prefab.instantiate()
	game_grid.add_child(sol)
	sol.position = c.position
	sol.type = c.type
	sol.on_done = pop_next_cell
	
	if randf() > 0.5:
		sol.x_velocity = -sol.x_velocity
	
	sol.y_velocity = randf_range(-600, 100)
