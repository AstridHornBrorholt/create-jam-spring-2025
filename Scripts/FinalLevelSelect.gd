extends Node2D

@onready var levelOption:LevelOption = $"LevelOption"

func _ready() -> void:
	levelOption.on_select = start_level
	levelOption.select_button.grab_focus()
		
	var map = MapSelector.empty.instantiate()
	levelOption.initialize(LevelOption.RewardType.Nothing, 
		map,
		levelOption.score_goal, 
		levelOption.time_limit)

func start_level(levelOption:LevelOption) -> void:
	CurrentRun.next_map = levelOption.map.to_array()
	CurrentRun.next_score_goal = levelOption.score_goal
	CurrentRun.next_time_limit = levelOption.time_limit
	CurrentRun.next_reward = levelOption.reward_type
	get_tree().change_scene_to_file("res://Scenes/Run Menus/GetReadyScreen.tscn")
