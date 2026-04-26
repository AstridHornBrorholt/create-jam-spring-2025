extends Node2D
class_name SolitaireEffect

const cell_prefab: PackedScene = preload("res://Prefabs/Cell.tscn")
@export var type:Cell.Type = Cell.Type.Standard
@export var stamp_rate:float = 0.015
@export var gravity:float = 1500
@export var bounciness:float = 0.7
@export var x_velocity:float = -500.
@export var y_velocity:float = -200.

var on_done:Callable
var stamp_timer:float = 0.
var y_max:float
var x_min:float
var x_max:float

func _ready() -> void:
	var viewport_rect:Rect2 = get_viewport_rect()
	x_min = -Cell.CELL_SIZE
	x_max = viewport_rect.size.x + Cell.CELL_SIZE
	y_max = viewport_rect.size.y - Cell.CELL_SIZE/2.

func _process(delta: float) -> void:
	position.x += x_velocity*delta
	position.y += y_velocity*delta
	y_velocity += gravity*delta
	
	if global_position.y > y_max:
		global_position.y = y_max
		y_velocity *= -bounciness
	
	if global_position.x < x_min or global_position.x > x_max:
		on_done.call()
		self.queue_free()
	
	stamp_timer += delta
	if stamp_timer >= stamp_rate:
		stamp_timer = 0
		var cell:Cell = cell_prefab.instantiate()
		cell.type = type
		self.get_parent().add_child(cell)
		cell.global_position = self.global_position
