extends Node2D
class_name AnimatedBackground

@export var max_falling:int = 15
@export var spawn_delay_min = 1
@export var spawn_delay_max = 6
@export var fall_speed_min = 30
@export var fall_speed_max = 100
@export var rotation_speed_min = -0.3
@export var rotation_speed_max =  0.3
@export var piece_types:Array[Cell.Type] = [Cell.Type.Standard]
@export var max_piece_size = 3
@export var min_piece_size = 5

@onready var tetriminos_animated = preload("res://Prefabs/TetriminosAnimated.tscn")

const min_starting_x = 0
const max_starting_x = 1920
const preferred_x_distance = 300
const starting_y = -400
const y_max = 1080 + 800

var spawn_delay = 0
var previous_x = 0

func _process(delta: float) -> void:
	spawn_delay -= delta
	if spawn_delay > 0 or get_child_count() > max_falling:
		return
	
	spawn_new()
	spawn_delay = randf_range(spawn_delay_min, spawn_delay_max)
	
	# Spawn some extra if low on pieces (mostly for initialization)
	if get_child_count() < 3:
		for i in 3:
			spawn_new()

func spawn_new():
	var minos:TetriminosAnimated = tetriminos_animated.instantiate()
	var size = randi_range(min_piece_size, max_piece_size)
	if randf() > 0.5 and min_piece_size < 4 and 4 < max_piece_size:
		size = 4
	var template:TetriminosTemplate = TetriminoGenerator.generate_tetrimino(size, piece_types)
	minos.setup(template)
	self.add_child(minos)
	
	# speed
	minos.falling_speed = randf_range(fall_speed_min, fall_speed_max)
	minos.rotation_speed = randf_range(rotation_speed_min, rotation_speed_max)
	
	# x, y
	var x = randf_range(min_starting_x, max_starting_x)
	
	# Try to not spawn the next one in the same place
	for i in 3:
		if abs(x - previous_x) > preferred_x_distance:
			break
		x = randf_range(min_starting_x, max_starting_x)
	previous_x = x
	
	var y = starting_y
	minos.position = Vector2(x, y)
	minos.y_max = y_max

func set_color(c:Color):
	modulate = c
