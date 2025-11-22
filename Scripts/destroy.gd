extends Node2D

@onready var next = $"Next"
@onready var next_start = next.position
@onready var next_wiggler:Wiggler = $"Next/Wiggler"
@onready var next_tetriminos:Tetriminos = $"Next/Wiggler/NextTetriminos"
@onready var next_target:Vector2 = $"NextTarget".position

@onready var held = $"Held"
@onready var held_start = held.position
@onready var held_wiggler:Wiggler = $"Held/Wiggler"
@onready var held_tetriminos:Tetriminos = $"Held/Wiggler/HeldTetriminos"
@onready var held_target:Vector2 = $"HeldTarget".position

@onready var select_next_button:Button = $"SelectNext"
@onready var select_held_button:Button = $"SelectHeld"

@onready var held_missing_text = $"HeldMissingText"

@onready var destroy_sound:AudioStreamPlayer = $"DestroySound"

var cell_collider = preload("res://Prefabs/CellCollider.tscn")

enum State { FlyingIn, Selecting, DestroyingSelected }
var state:State = State.FlyingIn

var fly_in_progress = 0.0
var fly_in_rate = 1.0

var destroy_progress = 0.0
var destroy_rate = 0.7

func _ready() -> void:
	select_next_button.visible = false
	select_held_button.visible = false
	next_wiggler.rotation_rate = 0
	held_wiggler.rotation_rate = 0
	held_missing_text.visible = false
	
	next_tetriminos.setup(CurrentRun.previously_next)
	held_tetriminos.setup(CurrentRun.previously_held)
	
	# Fallback intended for debugging.
	if CurrentRun.previously_next.is_empty():
		next_tetriminos.setup(CurrentRun.pop_from_stash())


func _process(delta: float) -> void:
	match state:
		State.FlyingIn:
			fly_in_progress = min(1., fly_in_progress + delta*fly_in_rate)
			next.position = lerp(next_start, next_target, fly_in_progress)
			held.position = lerp(held_start, held_target, fly_in_progress)
			if fly_in_progress >= 1:
				start_selecting()
		State.Selecting:
			if select_next_button.has_focus():
				next_wiggler.rotation_rate = 30
				held_wiggler.rotation_rate = 0
			elif select_held_button.has_focus():
				next_wiggler.rotation_rate = 0
				held_wiggler.rotation_rate = 30
		State.DestroyingSelected:
			destroy_progress = min(1, destroy_progress + delta*destroy_rate)
			if destroy_progress >= 1:
				# Debugging tip:
				#get_tree().change_scene_to_file("res://Scenes/Destroy.tscn")
				get_tree().change_scene_to_file("res://Scenes/next_level_select.tscn")

func start_selecting():
	state = State.Selecting
	select_next_button.visible = true
	select_next_button.grab_focus()
	
	# I hate chains like these -.-
	if held_tetriminos != null and held_tetriminos.template != null and !held_tetriminos.template.is_empty():
		select_held_button.visible = true
	else:
		held_missing_text.visible = true

func destroy(tetriminos:Tetriminos):
	destroy_sound.play()
	state = State.DestroyingSelected
	select_held_button.visible = false
	select_next_button.visible = false
	held_wiggler.rotation_rate = 0
	next_wiggler.rotation_rate = 0
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

func _on_select_next_button_down() -> void:
	destroy(next_tetriminos)


func _on_select_held_button_down() -> void:
	CurrentRun.previously_held = TetriminosTemplate.new([])
	destroy(held_tetriminos)
