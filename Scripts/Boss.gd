extends Node2D
class_name Boss

enum Type { None, Lightning, Monster, PlantPot, Plant, }

@export var game:TetrisGame
@export var background:AnimatedBackground

@onready var type:Type = CurrentRun.next_boss
@onready var animation_speed = Options.get_animation_speed()
@onready var angry_sfx:AudioStreamPlayer = $"Angry"
@onready var place_sfx:AudioStreamPlayer = $"Place"

var act_frequency:int
var description:String

func _ready() -> void:
	match type:
		Type.Lightning:
			description = "Intermittent lightning."
			act_frequency = 200
			background.fall_speed_min = 50
			background.fall_speed_min = 150
			background.min_piece_size = 1
			background.max_piece_size = 1
			background.piece_types = [Cell.Type.Lightning]
		Type.Monster:
			description = "Interloping monsters."
			act_frequency = 100
			background.set_color(Color(1, 1, 1, 0.5))
			background.fall_speed_min = 50
			background.fall_speed_min = 100
			background.min_piece_size = 1
			background.max_piece_size = 2
			background.piece_types = [Cell.Type.Monster]
		Type.PlantPot:
			description = "Unsanctioned planting"
			act_frequency = 200
			background.fall_speed_min = 50
			background.fall_speed_min = 70
			background.min_piece_size = 1
			background.max_piece_size = 1
			background.piece_types = [Cell.Type.PlantPot, Cell.Type.Plant]
		Type.Plant:
			description = "Kutzu"
			act_frequency = 150
			background.fall_speed_min = 50
			background.fall_speed_min = 150
			background.min_piece_size = 4
			background.max_piece_size = 8
			background.piece_types = [Cell.Type.Plant]

func tick_callback(tick) -> bool:
	animate(tick)
	if !will_act(tick):
		return false
	game.paused = true
	await act()
	game.paused = false
	return true

func will_act(tick) -> bool:
	if tick == 0:
		return false
	match type:
		_: return tick%act_frequency == 0

func act():
	match type:
		Type.Lightning:
			angry_sfx.play()
			await get_tree().create_timer(0.5/animation_speed).timeout
			var amount = randi_range(2, 4)
			for i in amount:
				var x = randi_range(0, game.WIDTH - 1)
				var y = randi_range(0, 5)
				if game.get_at(x, y) != null and game.get_at(x, y).type == Cell.Type.Lightning:
					continue
				game.remove_at(x, y)
				game.set_at(x, y, Cell.Type.Lightning)
				place_sfx.play()
				await get_tree().create_timer(0.5/animation_speed).timeout
		Type.Monster:
			var x = randi_range(0, game.WIDTH - 1)
			var y = first_empty_space(x)
			game.set_at(x, y, Cell.Type.Monster)
			place_sfx.play()
		Type.PlantPot:
			angry_sfx.play()
			await get_tree().create_timer(0.5/animation_speed).timeout
			var amount = randi_range(1, 3)
			for i in amount:
				var x = randi_range(0, game.WIDTH - 1)
				var y = first_empty_space(x)
				game.set_at(x, y, Cell.Type.PlantPot)
				place_sfx.play()
				await get_tree().create_timer(0.5/animation_speed).timeout
		Type.Plant:
			angry_sfx.play()
			await get_tree().create_timer(0.5/animation_speed).timeout
			var amount = randi_range(3, 5)
			var x:int
			var y:int
			x = randi_range(0, game.WIDTH - 1)
			y = first_empty_space(x)
				
			for i in amount:
				if game.get_at(x, y) == null or game.get_at(x, y).type != Cell.Type.Plant:
					game.remove_at(x, y)
					game.set_at(x, y, Cell.Type.Plant)
					place_sfx.play()
					await get_tree().create_timer(0.5/animation_speed).timeout
				# Grow in random non-plant direction, worm style
				for j in 20:
					var r = randf()
					if r < 0.50:
						y = min(game.HEIGHT - 1, y + 1)
					elif r < 0.66:
						y = max(0, y - 1)
					elif r < 0.82:
						x = max(0, x - 1)
					else:
						x = min(game.WIDTH - 1, x + 1)
					if game.get_at(x, y) == null or game.get_at(x, y).type != Cell.Type.Plant:
						break
		_: 
			pass

func first_empty_space(x:int) -> int:
	for y in range(0, game.HEIGHT):
		if game.get_at(x, y) != null:
			return max(0, y - 1)
	return game.HEIGHT - 1

func animate(tick):
	match type:
		Type.Lightning, Type.PlantPot, Type.Plant:
			var c:Color
			if tick%act_frequency == 0:
				c = Color.WHITE
			else:
				var progress = ((tick - 1)%act_frequency)/float(act_frequency)
				progress = progress**3
				c = lerp(Color(1, 1, 1, 0.1), Color(1, 1, 1, .95), progress)
			background.set_color(c)
