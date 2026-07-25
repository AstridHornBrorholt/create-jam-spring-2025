extends Node2D

@onready var animation_speed = Options.get_animation_speed()

# This was the piece which was in the "next" spot
@onready var next = $"Next"
var next_start:Vector2
@onready var next_wiggler:Wiggler = $"Next/Wiggler"
@onready var next_tetriminos:Tetriminos = $"Next/Wiggler/NextTetriminos"
@onready var next_target:Vector2 = $"NextTarget".position
@onready var swap_next_arrow = $"SwapNextArrow"

# You are offered to swap you next-piece with this.
@onready var next_offer = $"NextOffer"
@onready var next_offer_wiggler:Wiggler = $"NextOffer/Wiggler"
@onready var next_offer_tetriminos:Tetriminos = $"NextOffer/Wiggler/NextTetriminos"

@onready var held = $"Held"
var held_start:Vector2
@onready var held_wiggler:Wiggler = $"Held/Wiggler"
@onready var held_tetriminos:Tetriminos = $"Held/Wiggler/HeldTetriminos"
@onready var held_target:Vector2 = $"HeldTarget".position
@onready var swap_held_arrow = $"SwapHeldArrow"

@onready var held_offer = $"HeldOffer"
@onready var held_offer_wiggler:Wiggler = $"HeldOffer/Wiggler"
@onready var held_offer_tetriminos:Tetriminos = $"HeldOffer/Wiggler/HeldTetriminos"

@onready var falling = $"Falling"
var falling_start:Vector2
@onready var falling_wiggler:Wiggler = $"Falling/Wiggler"
@onready var falling_tetriminos:Tetriminos = $"Falling/Wiggler/FallingTetriminos"
@onready var falling_target:Vector2 = $"FallingTarget".position
@onready var swap_falling_arrow = $"SwapFallingArrow"

@onready var falling_offer = $"FallingOffer"
@onready var falling_offer_wiggler:Wiggler = $"FallingOffer/Wiggler"
@onready var falling_offer_tetriminos:Tetriminos = $"FallingOffer/Wiggler/FallingTetriminos"
@onready var falling_offer_target:Vector2 = $"FallingTarget".position

@onready var select_next_button:Button = $"SelectNext"
@onready var select_held_button:Button = $"SelectHeld"
@onready var select_falling_button:Button = $"SelectFalling"

@onready var held_missing_text = $"HeldMissingText"

@onready var swap_sound:AudioStreamPlayer = $"SwapSound"

enum State { Waiting, FlyingIn, Selecting, DestroyingSelected }
var state:State = State.Waiting


var wait_progress = 0.0
var wait_time = 0.3

var fly_in_progress = 0.0
var fly_in_rate = 0.9

var destroy_progress = 0.0
var destroy_rate = 0.7

func _ready() -> void:
	
	# Fallback intended for debugging.
	if CurrentRun.previously_next.is_empty():
		CurrentRun.previously_next = CurrentRun.pop_from_stash()
	if CurrentRun.previously_falling.is_empty():
		CurrentRun.previously_falling = CurrentRun.pop_from_stash()
		
	select_next_button.visible = false
	swap_next_arrow.visible = false
	select_held_button.visible = false
	swap_held_arrow.visible = false
	select_falling_button.visible = false
	swap_falling_arrow.visible = false
	next_wiggler.wiggle = false
	next_offer_wiggler.wiggle = false
	held_wiggler.wiggle = false
	held_offer_wiggler.wiggle = false
	held_missing_text.visible = false
	falling_wiggler.wiggle = false
	falling_offer_wiggler.wiggle = false
	
	next_tetriminos.setup(CurrentRun.previously_next)
	next_offer_tetriminos.setup(TetriminoGenerator.generate_tetrimino(next_tetriminos.get_size(), CurrentRun.game_mode.random_piece_types(CurrentRun.level)))
	next_offer.visible = false
	next_start = CurrentRun.previously_next_position
	next.position = next_start
	
	held_tetriminos.setup(CurrentRun.previously_held)
	held_offer_tetriminos.setup(TetriminoGenerator.generate_tetrimino(next_tetriminos.get_size(), CurrentRun.game_mode.random_piece_types(CurrentRun.level)))
	held_offer.visible = false
	held_start = CurrentRun.previously_held_position
	held.position = held_start
	
	falling_tetriminos.setup(CurrentRun.previously_falling)
	falling_offer_tetriminos.setup(TetriminoGenerator.generate_tetrimino(next_tetriminos.get_size(), CurrentRun.game_mode.random_piece_types(CurrentRun.level)))
	falling_offer.visible = false
	falling_start = CurrentRun.previously_falling_position
	falling.position = falling_start


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
				swap_next_arrow.modulate = Color("ffffff")
				next_wiggler.wiggle = true
				next_offer_wiggler.wiggle = true
				swap_held_arrow.modulate = Color("aaaaaa")
				held_wiggler.wiggle = false
				held_offer_wiggler.wiggle = false
				swap_falling_arrow.modulate = Color("aaaaaa")
				falling_wiggler.wiggle = false
				falling_offer_wiggler.wiggle = false
			elif select_held_button.has_focus():
				swap_next_arrow.modulate = Color("aaaaaa")
				next_wiggler.wiggle = false
				next_offer_wiggler.wiggle = false
				swap_held_arrow.modulate = Color("ffffff")
				held_wiggler.wiggle = true
				held_offer_wiggler.wiggle = true
				swap_falling_arrow.modulate = Color("aaaaaa")
				falling_wiggler.wiggle = false
				falling_offer_wiggler.wiggle = false
			elif select_falling_button.has_focus():
				swap_next_arrow.modulate = Color("aaaaaa")
				next_wiggler.wiggle = false
				next_offer_wiggler.wiggle = false
				swap_held_arrow.modulate = Color("aaaaaa")
				held_wiggler.wiggle = false
				held_offer_wiggler.wiggle = false
				swap_falling_arrow.modulate = Color("ffffff")
				falling_wiggler.wiggle = true
				falling_offer_wiggler.wiggle = true

func start_selecting():
	state = State.Selecting
	select_next_button.visible = true
	next_offer.visible = true
	swap_next_arrow.visible = true
	select_next_button.grab_focus()
	
	# I hate chains like these -.-
	if held_tetriminos != null and held_tetriminos.template != null and !held_tetriminos.template.is_empty():
		select_held_button.visible = true
		held_offer.visible = true
		swap_held_arrow.visible = true
	else:
		held_missing_text.visible = true
		held_offer.visible = false
		swap_held_arrow.visible = false
	
	select_falling_button.visible = true
	falling_offer.visible = true
	swap_falling_arrow.visible = true

func _on_select_next_mouse_entered() -> void:
	select_next_button.grab_focus()

func _on_select_held_mouse_entered() -> void:
	select_held_button.grab_focus()

func _on_select_falling_mouse_entered() -> void:
	select_falling_button.grab_focus()

###
# This is the most cantankerous code I have ever written. In my defense, I think I still have a bit of the flu.

func _on_select_next_pressed() -> void:
	var owned_position = next_tetriminos.position
	var offer_position = next_offer_tetriminos.position
	
	var temp = next_tetriminos
	next_tetriminos = next_offer_tetriminos
	next_offer_tetriminos = temp
	
	next_tetriminos.reparent(next_wiggler)
	next_tetriminos.position = owned_position
	next_offer_tetriminos.reparent(next_offer_wiggler)
	next_offer_tetriminos.position = offer_position
	
	CurrentRun.remove_from_permanent_stash(next_offer_tetriminos.template)
	CurrentRun.add_to_permanent_stash(next_tetriminos.template)
	
	swap_sound.play()
	
	CurrentRun.previously_next = next_tetriminos.template

func _on_select_held_pressed() -> void:
	var owned_position = held_tetriminos.position
	var offer_position = held_offer_tetriminos.position
	
	var temp = held_tetriminos
	held_tetriminos = held_offer_tetriminos
	held_offer_tetriminos = temp
	
	held_tetriminos.reparent(held_wiggler)
	held_tetriminos.position = owned_position
	held_offer_tetriminos.reparent(held_offer_wiggler)
	held_offer_tetriminos.position = offer_position
	
	CurrentRun.remove_from_permanent_stash(held_offer_tetriminos.template)
	CurrentRun.add_to_permanent_stash(held_tetriminos.template)
	
	swap_sound.play()
	
	CurrentRun.previously_held = held_tetriminos.template

func _on_select_falling_pressed() -> void:
	var owned_position = falling_tetriminos.position
	var offer_position = falling_offer_tetriminos.position
	
	var temp = falling_tetriminos
	falling_tetriminos = falling_offer_tetriminos
	falling_offer_tetriminos = temp
	
	falling_tetriminos.reparent(falling_wiggler)
	falling_tetriminos.position = owned_position
	falling_offer_tetriminos.reparent(falling_offer_wiggler)
	falling_offer_tetriminos.position = offer_position
	
	CurrentRun.remove_from_permanent_stash(falling_offer_tetriminos.template)
	CurrentRun.add_to_permanent_stash(falling_tetriminos.template)
	
	swap_sound.play()
	
	CurrentRun.previously_falling = falling_tetriminos.template
