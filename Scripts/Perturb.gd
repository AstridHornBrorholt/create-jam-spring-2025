extends Node2D

@onready var animation_speed = Options.get_animation_speed()

# This was the piece which was in the "next" spot
@onready var next:PerturbOption = $"Next"
@onready var held:PerturbOption = $"Held"
@onready var falling:PerturbOption = $"Falling"

var held_missing:bool
@onready var held_missing_text = $"HeldMissingText"

func _ready() -> void:
	# Fallback intended for debugging.
	if CurrentRun.previously_next.is_empty():
		CurrentRun.previously_next = CurrentRun.pop_from_stash()
	if CurrentRun.previously_falling.is_empty():
		CurrentRun.previously_falling = CurrentRun.pop_from_stash()
	
	next.setup(CurrentRun.previously_next, CurrentRun.previously_next_position)
	held.setup(CurrentRun.previously_held, CurrentRun.previously_held_position)
	falling.setup(CurrentRun.previously_falling, CurrentRun.previously_falling_position)
	
	held_missing = CurrentRun.previously_held == null or CurrentRun.previously_held.is_empty()
	held_missing_text.visible = held_missing
	
	# Set button navigation focus 
	var n:ButtonWithShadow = $"Next/PerturbButton"
	var h:ButtonWithShadow = $"Held/PerturbButton"
	var f:ButtonWithShadow = $"Falling/PerturbButton"
	var c:ButtonWithShadow = $"Continue"
	
	if held_missing:
		# ButtonWithShadow.set_focus(left, top, right, bottom, next, previous)
		n.set_focus(f, c, f, c, f, c)
		f.set_focus(n, c, n, c, c, n)
		c.set_focus(n, n, f, n, n, f)
	else:
		n.set_focus(f, c, h, c, h, c)
		h.set_focus(n, c, f, c, f, n)
		f.set_focus(h, c, n, c, c, h)
		c.set_focus(n, h, f, h, n, f)
	
	n.grab_focus()

func _on_next_on_perturbed(new_template: TetriminosTemplate) -> void:
	CurrentRun.previously_next = new_template

func _on_held_on_perturbed(new_template: TetriminosTemplate) -> void:
	CurrentRun.previously_held = new_template

func _on_falling_on_perturbed(new_template: TetriminosTemplate) -> void:
	CurrentRun.previously_falling = new_template
