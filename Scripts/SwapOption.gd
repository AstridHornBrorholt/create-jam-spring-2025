extends Node2D
class_name SwapOption

signal on_swapped(new_template:TetriminosTemplate)

@onready var animation_speed = Options.get_animation_speed()

@onready var wiggler:Wiggler = $"Wiggler"
@onready var tetriminos:Tetriminos = $"Wiggler/Tetriminos"
var wiggler_start:Vector2
@onready var wiggler_target:Vector2 = wiggler.global_position
@onready var swap_arrow = $"SwapArrow"

# You are offered to swap you next-piece with this.
@onready var offer_wiggler:Wiggler = $"OfferWiggler"
@onready var offer_tetriminos:Tetriminos = $"OfferWiggler/Tetriminos"

@onready var swap_button:Button = $"SwapButton"

@onready var swap_sound:AudioStreamPlayer = $"SwapSound"

enum State { Waiting, FlyingIn, Selecting }
var state:State = State.Waiting

var wait_progress = 0.0
var wait_time = 0.3

var fly_in_progress = 0.0
var fly_in_rate = 0.9

func setup(template:TetriminosTemplate, start_position:Vector2):
	tetriminos.setup(template)
	wiggler_start = start_position
	wiggler.global_position = wiggler_start
	offer_tetriminos.setup(TetriminoGenerator.generate_tetrimino(tetriminos.get_size(), CurrentRun.game_mode.random_piece_types(CurrentRun.level)))

func _ready() -> void:
	swap_button.visible = false
	swap_arrow.visible = false
	wiggler.wiggle = false
	
	offer_wiggler.wiggle = false
	offer_wiggler.visible = false
	
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
			if swap_button.has_focus():
				swap_arrow.modulate = Color("ffffff")
				wiggler.wiggle = true
				offer_wiggler.wiggle = true
			else:
				swap_arrow.modulate = Color("aaaaaa")
				wiggler.wiggle = false
				offer_wiggler.wiggle = false

func grab_focus(): 
	swap_button.grab_focus()

func start_selecting():
	state = State.Selecting
	if tetriminos.template.is_empty():
		return
	offer_wiggler.visible = true
	swap_button.visible = true
	swap_arrow.visible = true

func _on_swap_button_mouse_entered() -> void:
	swap_button.grab_focus()

func _on_swap_button_pressed() -> void:
	var temp:Tetriminos = tetriminos
	tetriminos = offer_tetriminos
	offer_tetriminos = temp
	
	var tempʹ:Vector2 = tetriminos.position
	tetriminos.reparent(wiggler)
	tetriminos.position = offer_tetriminos.position
	offer_tetriminos.reparent(offer_wiggler)
	offer_tetriminos.position = tempʹ
	
	CurrentRun.remove_from_permanent_stash(offer_tetriminos.template)
	CurrentRun.add_to_permanent_stash(tetriminos.template)
	
	swap_sound.play()
	
	on_swapped.emit(tetriminos.template)
