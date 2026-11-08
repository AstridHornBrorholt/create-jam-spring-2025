extends Node2D
class_name Boss

enum Type { None, Lightning, Monster, PlantPot, Plant, Concrete, Mirror, Sand}

@export var game:TetrisGame
@export var background:AnimatedBackground

@onready var type:Type = CurrentRun.next_boss if CurrentRun.level == CurrentRun.next_boss_level else Type.None
@onready var animation_speed = Options.get_animation_speed()
@onready var angry_sfx:AudioStreamPlayer = $"Angry"
@onready var place_sfx:AudioStreamPlayer = $"Place"

var act_frequency:int = INT16_MAX
var description:String

static func choose_random() -> Type:
	return randi_range(1, Boss.Type.size() - 1) as Boss.Type

static func get_description(t:Type) -> String:
	match t:
		Type.Lightning:
			return "Intermittent lightning"
		Type.Monster:
			return "Interloping monsters"
		Type.PlantPot:
			return "Unsanctioned planting"
		Type.Plant:
			return "Spreading vines"
		Type.Concrete:
			return "Rows of concrete"
		Type.Mirror:
			return "Rows of mirrors"
		Type.Sand:
			return "Sand storm"
		_: 
			return "error"

func _ready() -> void:
	match type:
		Type.Lightning:
			act_frequency = 200
			background.fall_speed_min = 50
			background.fall_speed_max = 150
			background.min_piece_size = 1
			background.max_piece_size = 1
			background.piece_types = [Cell.Type.Lightning]
		Type.Monster:
			act_frequency = 100
			background.set_color(Color(1, 1, 1, 0.5))
			background.fall_speed_min = 50
			background.fall_speed_max = 100
			background.min_piece_size = 1
			background.max_piece_size = 2
			background.piece_types = [Cell.Type.Monster]
		Type.PlantPot:
			act_frequency = 200
			background.fall_speed_min = 50
			background.fall_speed_max = 70
			background.min_piece_size = 1
			background.max_piece_size = 1
			background.piece_types = [Cell.Type.PlantPot, Cell.Type.Plant]
		Type.Plant:
			act_frequency = 150
			background.fall_speed_min = 50
			background.fall_speed_max = 150
			background.min_piece_size = 4
			background.max_piece_size = 8
			background.piece_types = [Cell.Type.Plant]
		Type.Concrete:
			act_frequency = 210
			background.fall_speed_min = 40
			background.fall_speed_max = 60
			background.min_piece_size = 4
			background.max_piece_size = 4
			background.piece_types = [Cell.Type.Concrete]
		Type.Mirror:
			act_frequency = 200
			background.fall_speed_min = 70
			background.fall_speed_max = 300
			background.min_piece_size = 4
			background.max_piece_size = 4
			background.piece_types = [Cell.Type.Mirror]
		Type.Sand:
			background.set_color(Color(1, 1, 1, 0.5))
			act_frequency = 40
			background.fall_speed_min = 100
			background.fall_speed_max = 300
			background.min_piece_size = 1
			background.max_piece_size = 2
			background.piece_types = [Cell.Type.Sand]
			

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
			play(angry_sfx)
			await get_tree().create_timer(0.5/animation_speed).timeout
			var amount = randi_range(2, 4)
			for i in amount:
				var x = rand_x()
				var y = randi_range(0, 5)
				if game.get_at(x, y) != null and game.get_at(x, y).type == Cell.Type.Lightning:
					continue
				game.remove_at(x, y)
				game.set_at(x, y, Cell.Type.Lightning)
				play(place_sfx)
				await get_tree().create_timer(0.5/animation_speed).timeout
		Type.Monster:
			var x = rand_x()
			var y = first_empty_space(x)
			game.set_at(x, y, Cell.Type.Monster)
			play(place_sfx)
		Type.PlantPot:
			play(angry_sfx)
			await get_tree().create_timer(0.5/animation_speed).timeout
			var amount = randi_range(1, 3)
			for i in amount:
				var x = rand_x()
				var y = first_empty_space(x)
				game.set_at(x, y, Cell.Type.PlantPot)
				play(place_sfx)
				await get_tree().create_timer(0.5/animation_speed).timeout
		Type.Plant:
			play(angry_sfx)
			await get_tree().create_timer(0.5/animation_speed).timeout
			var amount = randi_range(5, 8)
			var x:int
			var y:int
			x = rand_x()
			y = first_empty_space(x)
				
			for i in amount:
				if game.get_at(x, y) == null or game.get_at(x, y).type != Cell.Type.Plant:
					game.remove_at(x, y)
					game.set_at(x, y, Cell.Type.Plant)
					play(place_sfx)
					await get_tree().create_timer(0.2/animation_speed).timeout
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
		Type.Concrete:
			play(angry_sfx)
			shift_up()
			var empty_spaces = []
			for i in 3:
				empty_spaces.push_back(randi_range(0, game.WIDTH - 1))
			for x in game.WIDTH - 1:
				if not x in empty_spaces:
					var cell = Cell.Type.Concrete if randf() < 0.5 else Cell.Type.ConcreteSemiBroken
					game.set_at(x, game.HEIGHT - 1, cell)
					play(place_sfx, 1.4)
					await get_tree().create_timer(0.1/animation_speed).timeout
		Type.Mirror:
			play(angry_sfx)
			shift_up()
			var empty_spaces = []
			for i in 5:
				empty_spaces.push_back(randi_range(0, game.WIDTH - 1))
			for x in game.WIDTH - 1:
				if not x in empty_spaces:
					var cell = Cell.Type.Mirror
					game.set_at(x, game.HEIGHT - 1, cell)
					play(place_sfx, 0.6)
					await get_tree().create_timer(0.1/animation_speed).timeout
		Type.Sand:
			var x = rand_x()
			var y = max(0, first_empty_space(x) - randi_range(2, 4))
			game.set_at(x, y, Cell.Type.Sand)
			play(place_sfx)
		_: 
			pass

func play(sfx:AudioStreamPlayer, pitch:float = 1.0):
	sfx.pitch_scale = pitch
	sfx.play()

# Choose random x position, preferring to stay out of the way of the falling piece
func rand_x() -> int:
	var x:int
	for i in 10:
		x = randi_range(0, game.WIDTH - 1)
		var falling = game.falling_tetriminos
		if falling == null:
			break
		if abs(x - falling.grid_pos.x) > 1:
			break
	return x

func first_empty_space(x:int) -> int:
	for y in game.HEIGHT:
		if game.get_at(x, y) != null:
			return max(0, y - 1)
	return game.HEIGHT - 1

func shift_up():
	# Clear top row
	for x in game.WIDTH:
		game.remove_at(x, 0)
	for x in game.WIDTH:
		for y in game.HEIGHT:
			var cell = game.get_at(x, y)
			if cell == null:
				continue
			game.remove_at(x, y)
			game.set_at(x, y - 1, cell.type)

func animate(tick):
	match type:
		Type.Lightning, Type.PlantPot, Type.Plant, Type.Concrete, Type.Mirror:
			var c:Color
			if tick%act_frequency == 0:
				c = Color.WHITE
			else:
				var progress = ((tick - 1)%act_frequency)/float(act_frequency)
				progress = progress**3
				c = lerp(Color(1, 1, 1, 0.1), Color(1, 1, 1, .95), progress)
			background.set_color(c)
