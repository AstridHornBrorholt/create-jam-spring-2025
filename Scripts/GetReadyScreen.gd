extends Node2D

@onready var stats:RichTextLabel = $"Stats"
@onready var begin_button:Button = $"Interactive/BeginButton"

func _ready() -> void:
	begin_button.grab_focus()
	var win_level = CurrentRun.game_mode.win_level
	var score_target = CurrentRun.next_score_goal
	var time = CurrentRun.next_time_limit
	var minutes:int = floor(time/60.)
	var seconds:int = time - minutes*60
	stats.text = ("[color=blue]Level\t" + str(CurrentRun.level) + "[/color] of " + str(win_level) + "\n" +
				  "Target\t[color=yellow]" + str(score_target) + "[/color]\n" +
				  "Time \t\t[color=blue]" + str(minutes) + ":" + str(seconds) + "[/color]")
	

func _on_begin_button_button_down() -> void:
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")
