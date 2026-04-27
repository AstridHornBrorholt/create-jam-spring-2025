extends Node2D

@onready var levelOption1:LevelOption = $"LevelOption1"
@onready var levelOption2:LevelOption = $"LevelOption2"
@onready var levelOption3:LevelOption = $"LevelOption3"


func _ready() -> void:
	if CurrentRun.level == CurrentRun.game_mode.win_level:
		get_tree().change_scene_to_file("res://Scenes/Run Menus/FinalLevelSelect.tscn")
	levelOption1.on_select = start_level
	levelOption2.on_select = start_level
	levelOption3.on_select = start_level
	
	var b1:Button = levelOption1.select_button
	var b2:Button = levelOption2.select_button
	var b3:Button = levelOption3.select_button
	
	b2.grab_focus()
	b1.focus_neighbor_left = b3.get_path()
	b2.focus_neighbor_left = b1.get_path()
	b3.focus_neighbor_left = b2.get_path()
	b1.focus_next = b3.get_path()
	b2.focus_next = b1.get_path()
	b3.focus_next = b2.get_path()
	b1.focus_neighbor_right = b2.get_path()
	b2.focus_neighbor_right = b3.get_path()
	b3.focus_neighbor_right = b1.get_path()
	b1.focus_next = b2.get_path()
	b2.focus_next = b3.get_path()
	b3.focus_next = b1.get_path()

func start_level(levelOption:LevelOption) -> void:
	CurrentRun.next_map = levelOption.map.to_array()
	CurrentRun.next_score_goal = levelOption.score_goal
	CurrentRun.next_time_limit = levelOption.time_limit
	CurrentRun.next_reward = levelOption.reward_type
	get_tree().change_scene_to_file("res://Scenes/Run Menus/GetReadyScreen.tscn")
