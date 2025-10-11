extends Node2D
@onready var back_button:Button = $"Interactive/BackButton"
@onready var music_volume_slider:Slider = $"Music Volume Slider"
@onready var sfx_volume_slider:Slider = $"SFX Slider"

@onready var music_player:AudioStreamPlayer = $"Tetrogue-Menu"
@onready var music_player_volume = music_player.volume_linear
@onready var grabber_grab_sound:AudioStreamPlayer = $"Grab"
@onready var grabber_grab_volume = grabber_grab_sound.volume_linear
@onready var grabber_release_sound:AudioStreamPlayer = $"Release"
@onready var grabber_release_volume = grabber_release_sound.volume_linear

var grabbing:bool = false
var config:ConfigFile

func _ready() -> void:
	back_button.grab_focus()
	music_volume_slider.value = Options.get_music_volume()
	sfx_volume_slider.value = Options.get_sfx_volume()

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main Menu.tscn")


func _on_music_volume_slider_drag_started() -> void:
	grabber_grab_sound.play()
	grabbing = true

func _on_music_volume_slider_value_changed(value: float) -> void:
	music_player.volume_linear = music_player_volume*value
	Options.set_music_volume(value)
	if not grabbing:
		grabber_release_sound.play()

func _on_music_volume_slider_drag_ended(value_changed: bool) -> void:
	grabber_release_sound.play()
	grabbing = false


func _on_sfx_slider_drag_started() -> void:
	grabber_grab_sound.play()
	grabbing = true

func _on_sfx_slider_value_changed(value: float) -> void:
	grabber_grab_sound.volume_linear = grabber_grab_volume*value
	grabber_release_sound.volume_linear = grabber_release_volume*value
	Options.set_sfx_volume(value)
	if not grabbing:
		grabber_release_sound.play()

func _on_sfx_slider_drag_ended(value_changed: bool) -> void:
	grabber_release_sound.play()
	grabbing = false


func _on_music_volume_slider_gui_input(event: InputEvent) -> void:
	return
	_on_music_volume_slider_drag_ended(true) # Go ahead. Refactor. You'll feel better :3


func _on_sfx_slider_gui_input(event: InputEvent) -> void:
	return
	_on_sfx_slider_drag_ended(true)
