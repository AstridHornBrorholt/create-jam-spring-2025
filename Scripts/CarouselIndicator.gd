extends Node2D

@export var indicator:PackedScene

@export var length = 4
@export var current = 0
@export var spacing = 60
@export var scale_when_highlighted = 3
@export var scale_when_not_highlighted = 2

func _ready() -> void:
	set_length(length)

func set_length(length):
	# Clear previous
	for c in get_children():
		c.free()
		
	var offset = -spacing*(length - 1)/2
	for i in length:
		var square = indicator.instantiate()
		add_child(square)
		square.position.x = offset + i*spacing
	
	set_current(current)

func set_color(i:int, color:Color):
	var c:Node2D = get_children()[i]
	c.modulate = color

func set_current(current:int):
	var i = 0
	for c:Node2D in get_children():
		if i == current:
			c.scale = Vector2.ONE*scale_when_highlighted
		else:
			c.scale = Vector2.ONE*scale_when_not_highlighted
		i += 1
