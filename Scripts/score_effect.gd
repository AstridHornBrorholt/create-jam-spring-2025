extends Node2D

var rigid_body: RigidBody2D
var label: Label
var is_mult: bool = false
const time_alive: float = 1.0
var time_left_alive: float = time_alive

func _ready() -> void:
	rigid_body = $RigidBody2D
	label = $RigidBody2D/Label
	rigid_body.apply_impulse(Vector2(randf_range(-100., 100.), randf_range(0, 0)), Vector2(0, 0))

func set_is_mult(b:bool):
	is_mult = b

func set_score(score: int):
	label.text = "+" + str(score)
	
	var color:Color
	if is_mult:
		color = Color.RED
	else:
		color = Color.YELLOW.lerp(Color.INDIGO, clampf(score / 100.0, 0.0, 1.0))	
	label.add_theme_color_override("font_color", color)
	
	var font_size:int
	if is_mult:
		font_size = 40
	else:
		font_size = floor(lerpf(20.0, 50.0, clampf(score / 100.0, 0.0, 1.0)))
	label.add_theme_font_size_override("font_size", font_size)
	

func _process(delta: float) -> void:
	time_left_alive -= delta
	if time_left_alive < 0:
		queue_free()
		return
	
	label.modulate.a = ease(time_left_alive / time_alive, 0.33)
