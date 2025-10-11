extends Node2D

func _ready() -> void:
	$"Interactive/PlayButton".grab_focus()

func _on_play_button_pressed() -> void:
	CurrentRun.reset()
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")


func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Options.tscn")
	
func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Credits.tscn")


func _on_instructions_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Instructions1.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()
