extends Node2D

@onready var exit_button:TextureButton = $"Interactive/ExitButton"

func _ready() -> void:
	$"Interactive/PlayButton".grab_focus()

func _on_play_button_pressed() -> void:
	CurrentRun.reset()
	get_tree().change_scene_to_file("res://Scenes/Main Menu/GameMode.tscn")


func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main Menu/Options.tscn")
	
func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main Menu/Credits.tscn")


func _on_instructions_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main Menu/Instructions1.tscn")


func _on_exit_button_pressed() -> void:
	if OS.get_name() == "Web":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
