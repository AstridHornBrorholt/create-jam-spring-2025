extends Node2D

@onready var animation_speed = Options.get_animation_speed()

@onready var next = $"Next"
var next_start:Vector2
@onready var next_wiggler:Wiggler = $"Next/Wiggler"
@onready var next_tetriminos:Tetriminos = $"Next/Wiggler/NextTetriminos"
@onready var next_target:Vector2 = $"NextTarget".position

@onready var held = $"Held"
var held_start:Vector2
@onready var held_wiggler:Wiggler = $"Held/Wiggler"
@onready var held_tetriminos:Tetriminos = $"Held/Wiggler/HeldTetriminos"
@onready var held_target:Vector2 = $"HeldTarget".position

@onready var falling = $"Falling"
var falling_start:Vector2
@onready var falling_wiggler:Wiggler = $"Falling/Wiggler"
@onready var falling_tetriminos:Tetriminos = $"Falling/Wiggler/FallingTetriminos"
@onready var falling_target:Vector2 = $"FallingTarget".position

@onready var select_next_button:Button = $"SelectNext"
@onready var select_held_button:Button = $"SelectHeld"
@onready var select_falling_button:Button = $"SelectFalling"

@onready var held_missing_text = $"HeldMissingText"

@onready var destroy_sound:AudioStreamPlayer = $"DestroySound"

var cell_collider = preload("res://Prefabs/CellCollider.tscn")

enum State { Waiting, FlyingIn, Selecting, DestroyingSelected }
var state:State = State.Waiting

var wait_progress = 0.0
var wait_time = 0.2

var fly_in_progress = 0.0
var fly_in_rate = 0.5

var destroy_progress = 0.0
var destroy_rate = 0.7

func _ready() -> void:
	select_next_button.visible = false
	select_held_button.visible = false
	select_falling_button.visible = false
	next_wiggler.rotation_rate = 0
	held_wiggler.rotation_rate = 0
	held_missing_text.visible = false
	falling_wiggler.rotation_rate = 0
	
	next_tetriminos.setup(CurrentRun.previously_next)
	next_start = CurrentRun.previously_next_position
	next.position = next_start
	held_tetriminos.setup(CurrentRun.previously_held)
	held_start = CurrentRun.previously_held_position
	held.position = held_start
	falling_tetriminos.setup(CurrentRun.previously_falling)
	falling_start = CurrentRun.previously_falling_position
	falling.position = falling_start
	
	# Fallback intended for debugging.
	if CurrentRun.previously_next.is_empty():
		next_tetriminos.setup(CurrentRun.pop_from_stash())
	if CurrentRun.previously_falling.is_empty():
		falling_tetriminos.setup(CurrentRun.pop_from_stash())


func _process(delta: float) -> void:
	match state:
		State.Waiting:
			wait_progress = wait_progress + delta*animation_speed
			if wait_progress > wait_time:
				state = State.FlyingIn
		State.FlyingIn:
			fly_in_progress = min(1., fly_in_progress + delta*fly_in_rate*animation_speed)
			next.position = lerp(next_start, next_target, fly_in_progress)
			held.position = lerp(held_start, held_target, fly_in_progress)
			falling.position = lerp(falling_start, falling_target, fly_in_progress)
			if fly_in_progress >= 1:
				start_selecting()
		State.Selecting:
			if select_next_button.has_focus():
				next_wiggler.rotation_rate = 30
				held_wiggler.rotation_rate = 0
				falling_wiggler.rotation_rate = 0
			elif select_held_button.has_focus():
				next_wiggler.rotation_rate = 0
				held_wiggler.rotation_rate = 30
				falling_wiggler.rotation_rate = 0
			elif select_falling_button.has_focus():
				next_wiggler.rotation_rate = 0
				falling_wiggler.rotation_rate = 30
		State.DestroyingSelected:
			destroy_progress = min(1, destroy_progress + delta*destroy_rate)
			if destroy_progress >= 1:
				# Debugging tip:
				#get_tree().change_scene_to_file("res://Scenes/Run Menus/Destroy.tscn")
				get_tree().change_scene_to_file("res://Scenes/Run Menus/NextLevelSelect.tscn")

func start_selecting():
	state = State.Selecting
	select_next_button.visible = true
	select_next_button.grab_focus()
	
	# I hate chains like these -.-
	if held_tetriminos != null and held_tetriminos.template != null and !held_tetriminos.template.is_empty():
		select_held_button.visible = true
	else:
		held_missing_text.visible = true
	
	select_falling_button.visible = true

func destroy(tetriminos:Tetriminos):
	destroy_sound.play()
	state = State.DestroyingSelected
	select_held_button.visible = false
	select_next_button.visible = false
	select_falling_button.visible = false
	held_wiggler.rotation_rate = 0
	next_wiggler.rotation_rate = 0
	falling_wiggler.rotation_rate = 0
	CurrentRun.remove_from_permanent_stash(tetriminos.template)
	
	for cell in tetriminos.cells:
		var collider:RigidBody2D = cell_collider.instantiate()
		collider.position = cell.position
		collider.scale = cell.scale
		var angle = randf_range(-3*PI/4, -PI/4) # I only want it to be on upwards trajectories
		var magnitude = randf_range(500., 1200.)
		collider.linear_velocity = (Vector2(cos(angle)*magnitude, sin(angle)*magnitude))
		cell.get_parent().add_child(collider)
		cell.reparent(collider)

func _on_select_next_mouse_entered() -> void:
	select_next_button.grab_focus()

func _on_select_held_mouse_entered() -> void:
	select_held_button.grab_focus()

func _on_select_falling_mouse_entered() -> void:
	select_falling_button.grab_focus()

func _on_select_next_pressed() -> void:
	if held_tetriminos != null and held_tetriminos.template != null and next_tetriminos.template.equals(held_tetriminos.template):
		CurrentRun.previously_next = TetriminosTemplate.new([])
	destroy(next_tetriminos)

func _on_select_held_pressed() -> void:
	CurrentRun.previously_held = TetriminosTemplate.new([])
	destroy(held_tetriminos)

func _on_select_falling_pressed() -> void:
	CurrentRun.previously_falling = TetriminosTemplate.new([])
	destroy(falling_tetriminos)
