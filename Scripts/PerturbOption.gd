extends Node2D
class_name PerturbOption

signal on_perturbed(new_template:TetriminosTemplate)

var pertubations_left = 3

@onready var animation_speed = Options.get_animation_speed()

@onready var wiggler:Wiggler = $"Wiggler"
@onready var tetriminos:Tetriminos = $"Wiggler/Tetriminos"
var original_template:TetriminosTemplate
var wiggler_start:Vector2
@onready var wiggler_target:Vector2 = wiggler.global_position

@onready var perturb_button:Button = $"PerturbButton"
@onready var original_perturb_button_text:String = perturb_button.text

@onready var perturb_sound:AudioStreamPlayer = $"PerturbSound"
@onready var error_sound:AudioStreamPlayer = $"ErrorSound"

enum State { Waiting, FlyingIn, Selecting }
var state:State = State.Waiting

var wait_progress = 0.0
var wait_time = 0.3

var fly_in_progress = 0.0
var fly_in_rate = 0.9

func setup(template:TetriminosTemplate, start_position:Vector2):
	original_template = template
	tetriminos.setup(template)
	wiggler_start = start_position
	wiggler.global_position = wiggler_start

func _ready() -> void:
	perturb_button.visible = false
	wiggler.wiggle = false
	
	wiggler.global_position = wiggler_start

func _process(delta: float) -> void:
	match state:
		State.Waiting:
			wait_progress = wait_progress + delta*animation_speed
			if wait_progress > wait_time:
				state = State.FlyingIn
		State.FlyingIn:
			fly_in_progress = min(1., fly_in_progress + delta*fly_in_rate*animation_speed)
			wiggler.global_position = lerp(wiggler_start, wiggler_target, fly_in_progress)
			if fly_in_progress >= 1:
				start_selecting()
		State.Selecting:
			if perturb_button.has_focus():
				wiggler.wiggle = true
			else:
				wiggler.wiggle = false

func grab_focus(): 
	perturb_button.grab_focus()

func start_selecting():
	state = State.Selecting
	if tetriminos.template.is_empty():
		return
	update_perturb_button()
	perturb_button.visible = true

func update_perturb_button():
	perturb_button.text = original_perturb_button_text.replace("?", str(pertubations_left))
	if pertubations_left < 1:
		perturb_button.modulate = Color("#777777")

func _on_perturb_button_mouse_entered() -> void:
	perturb_button.grab_focus()

func _on_perturb_button_pressed() -> void:
	if pertubations_left < 1:
		error_sound.play()
		return
	pertubations_left -= 1
	update_perturb_button()
	
	var previous_template = tetriminos.template
	
	var cells:Array[Cell.Type] = original_template.get_cell_types()
	
	var new_template = previous_template
	for __ in 100:
		if !new_template.equals(previous_template):
			break
		new_template = TetriminoGenerator.random_piece(cells)
	
	tetriminos.setup(new_template)
	CurrentRun.remove_from_permanent_stash(previous_template)
	CurrentRun.add_to_permanent_stash(new_template)
	
	perturb_sound.play()
	perturb_sound.pitch_scale += 0.6
	wiggler.rotation_rate += 10
	on_perturbed.emit(tetriminos.template)
