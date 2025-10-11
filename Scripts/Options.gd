extends Node2D
@onready var back_button:Button = $"Interactive/BackButton"

# Also hijacked for instructions pages

func _ready() -> void:
	back_button.grab_focus()

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main Menu.tscn")
