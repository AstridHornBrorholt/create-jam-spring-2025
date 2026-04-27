extends Node2D
class_name HereTakeThis

@onready var selection_option:SelectionOption = $"SelectionOption"
@onready var tetriminos:Tetriminos = $"SelectionOption/Tetriminos"
@onready var fly_in_start:Node2D = $"FlyInStart"

func _ready() -> void:
	var template = get_legendary_piece()
	selection_option.setup(template, 0)
	selection_option.starting_position = fly_in_start.global_position
	selection_option.flying_in_speed = 0.2
	selection_option.fly_in()
	
func get_legendary_piece() -> TetriminosTemplate:
	return [
		TetriminosTemplate.new([
			CellTemplate.new(1, 0, Cell.Type.Multiplier),
			CellTemplate.new(0, 0, Cell.Type.Multiplier),
			CellTemplate.new(-1, 0, Cell.Type.Multiplier),
			CellTemplate.new(-2, 0, Cell.Type.Multiplier),
		]),
		TetriminosTemplate.new([
			CellTemplate.new(1, 0, Cell.Type.Anvil),
			CellTemplate.new(0, 0, Cell.Type.Anvil),
			CellTemplate.new(-1, 0, Cell.Type.Anvil),
			CellTemplate.new(-2, 0, Cell.Type.Anvil),
		]),
		TetriminosTemplate.new([
			CellTemplate.new(1, 0, Cell.Type.Gold),
			CellTemplate.new(0, 0, Cell.Type.Gold),
			CellTemplate.new(-1, 0, Cell.Type.Gold),
			CellTemplate.new(0, 1, Cell.Type.Gold),
			CellTemplate.new(0, -1, Cell.Type.Gold),
			CellTemplate.new(1, 1, Cell.Type.Gold),
			CellTemplate.new(-1, 1, Cell.Type.Gold),
			CellTemplate.new(1, -1, Cell.Type.Gold),
			CellTemplate.new(-1, -1, Cell.Type.Gold),
		]),
		TetriminosTemplate.new([
			CellTemplate.new(0, 0, Cell.Type.Lightning),
			CellTemplate.new(0, 1, Cell.Type.Balloon),
			CellTemplate.new(1, 0, Cell.Type.Lightning),
			CellTemplate.new(1, 1, Cell.Type.Balloon),
		]),
		TetriminosTemplate.new([
			CellTemplate.new(3, 0, Cell.Type.Sand),
			CellTemplate.new(2, 0, Cell.Type.Sand),
			CellTemplate.new(1, 0, Cell.Type.Sand),
			CellTemplate.new(0, 0, Cell.Type.Sand),
			CellTemplate.new(-1, 0, Cell.Type.Sand),
			CellTemplate.new(-2, 0, Cell.Type.Sand),
			CellTemplate.new(-3, 0, Cell.Type.Sand),
		]),
		TetriminosTemplate.new([
			CellTemplate.new(1, 0, Cell.Type.Clock),
			CellTemplate.new(0, 0, Cell.Type.Clock),
			CellTemplate.new(-1, 0, Cell.Type.Clock),
			CellTemplate.new(0, 1, Cell.Type.Clock),
			CellTemplate.new(0, -1, Cell.Type.Clock),
		]),
		TetriminosTemplate.new([
			CellTemplate.new(1, 0, Cell.Type.Bomb),
			CellTemplate.new(0, 0, Cell.Type.Bomb),
			CellTemplate.new(-1, 0, Cell.Type.Bomb),
			CellTemplate.new(-2, 0, Cell.Type.Bomb),
			CellTemplate.new(1, 1, Cell.Type.Bomb),
			CellTemplate.new(0, 1, Cell.Type.Bomb),
			CellTemplate.new(-1, 1, Cell.Type.Bomb),
			CellTemplate.new(-2, 1, Cell.Type.Bomb),
		]),
		TetriminosTemplate.new([
			CellTemplate.new(3, 0, Cell.Type.Mole),
			CellTemplate.new(2, 0, Cell.Type.Mole),
			CellTemplate.new(1, 0, Cell.Type.Mole),
			CellTemplate.new(0, 0, Cell.Type.Mole),
			CellTemplate.new(-1, 0, Cell.Type.Mole),
			CellTemplate.new(-2, 0, Cell.Type.Mole),
			CellTemplate.new(-3, 0, Cell.Type.Mole),
		]),
	].pick_random()

func register_picked(_id):
	get_tree().change_scene_to_file("res://Scenes/Run Menus/GetReadyScreen.tscn")
