extends Node2D
class_name Boss

enum Type { None, Baraqiel, }

@onready var type:Type = CurrentRun.next_boss
@onready var game:TetrisGame = $"../../TetrisGame"
@onready var animation_speed = Options.get_animation_speed()
@onready var angry_sfx:AudioStreamPlayer = $"Angry"
@onready var place_sfx:AudioStreamPlayer = $"Place"

func get_description() -> String:
	match type:
		Type.Baraqiel:
			return "Unwelcome lightning."
		_: 
			return "error"

func tick_callback(tick) -> bool:
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
		Type.Baraqiel:
			return tick%150 == 0
		_: return false

func act():
	match type:
		Type.Baraqiel:
			angry_sfx.play()
			await get_tree().create_timer(0.8/animation_speed).timeout
			var amount = randi_range(2, 4)
			for i in amount:
				var x = randi_range(0, game.WIDTH - 1)
				var y = randi_range(0, game.HEIGHT - 1)
				game.remove_at(x, y)
				game.set_at(x, y, Cell.Type.Lightning)
				place_sfx.play()
				await get_tree().create_timer(0.2/animation_speed).timeout
		_: 
			pass
