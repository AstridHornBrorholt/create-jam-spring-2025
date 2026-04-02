extends Node2D

@onready var selectButton1:Button = $"SelectButton1"
@onready var levelOption1:LevelOption = $"LevelOption1"
@onready var selectButton2:Button = $"SelectButton2"
@onready var levelOption2:LevelOption = $"LevelOption2"
@onready var selectButton3:Button = $"SelectButton3"
@onready var levelOption3:LevelOption = $"LevelOption3"

var focusedButton:Button
var focusedLevelOption:LevelOption

# Animation
var focus_progress:float = 0.0
const focus_rate = 6.0

var scale_focus = Vector2.ONE
@onready var scale_no_focus = levelOption1.transform.get_scale()
var color_focus = Color("#ffffffff")
@onready var color_no_focus = levelOption1.modulate

func _ready() -> void:
	selectButton2.grab_focus()

func start_level(levelOption:LevelOption) -> void:
	CurrentRun.next_map = levelOption.map.to_array()
	CurrentRun.next_score_goal = levelOption.score_goal
	CurrentRun.next_time_limit = levelOption.time_limit
	CurrentRun.next_reward = levelOption.reward_type
	get_tree().change_scene_to_file("res://Scenes/Run Menus/GetReadyScreen.tscn")

func _process(delta: float) -> void:
	levelOption1.modulate = color_no_focus
	levelOption1.scale = scale_no_focus
	levelOption2.modulate = color_no_focus
	levelOption2.scale = scale_no_focus
	levelOption3.modulate = color_no_focus
	levelOption3.scale = scale_no_focus
	
	focus_progress += delta*focus_rate
	focus_progress = min(focus_progress, 1)
	focusedLevelOption.scale = lerp(scale_no_focus, scale_focus, focus_progress)
	focusedLevelOption.modulate = color_focus


func _on_select_button_1_focus_entered() -> void:
	focus_progress = 0.
	focusedButton = selectButton1
	focusedLevelOption = levelOption1
	
func _on_select_button_2_focus_entered() -> void:
	focus_progress = 0.
	focusedButton = selectButton2
	focusedLevelOption = levelOption2

func _on_select_button_3_focus_entered() -> void:
	focus_progress = 0.
	focusedButton = selectButton3
	focusedLevelOption = levelOption3


func _on_select_button_1_mouse_entered() -> void:
	selectButton1.grab_focus()


func _on_select_button_2_mouse_entered() -> void:
	selectButton2.grab_focus()


func _on_select_button_3_mouse_entered() -> void:
	selectButton3.grab_focus()


func _on_select_button_1_button_down() -> void:
	start_level(levelOption1)


func _on_select_button_2_button_down() -> void:
	start_level(levelOption2)


func _on_select_button_3_button_down() -> void:
	start_level(levelOption3)
