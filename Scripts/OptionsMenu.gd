extends Node2D
@onready var back_button:Button = $"Interactive/BackButton"
@onready var music_volume_slider:Slider = $"Music Volume Slider"
@onready var sfx_volume_slider:Slider = $"SFX Slider"
@onready var animation_speed_slider:Slider = $"Animation Speed Slider"
@onready var spinner:RichTextLabel = $"Spinner"

@onready var music_player:AudioStreamPlayer = $"Tetrogue-Menu"
@onready var music_player_volume = music_player.volume_linear
@onready var grabber_grab_sound:AudioStreamPlayer = $"Grab"
@onready var grabber_grab_volume = grabber_grab_sound.volume_linear
@onready var grabber_release_sound:AudioStreamPlayer = $"Release"
@onready var grabber_release_volume = grabber_release_sound.volume_linear

const spin_animation = "⣾⣽⣻⢿⡿⣟⣯⣷"
const spin_rate = 0.4
var spin_progress = 0.0
var spin_index:int = 0

var grabbing:bool = false
var grabbing_slider:bool = false
var config:ConfigFile

func _ready() -> void:
	back_button.grab_focus()
	music_volume_slider.value = Options.get_music_volume()
	sfx_volume_slider.value = Options.get_sfx_volume()
	animation_speed_slider.value = Options.get_animation_speed()
	spinner.text = ""

func _process(delta: float) -> void:
	if animation_speed_slider.has_focus() or grabbing_slider:
		var speed = Options.get_animation_speed()
		spin_progress += delta*speed
		if spin_progress > spin_rate:
			spin_progress = 0
			spin_index = (spin_index + 1)%len(spin_animation)
		spinner.text = str(speed) + " " + spin_animation[spin_index]
	else:
		spinner.text = ""

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

func _on_animation_speed_slider_value_changed(value: float) -> void:
	Options.set_animation_speed(value)
	if not grabbing:
		grabber_release_sound.play()

func _on_animation_speed_slider_drag_started() -> void:
	grabber_grab_sound.play()
	grabbing = true
	grabbing_slider = true


func _on_animation_speed_slider_drag_ended(value_changed: bool) -> void:
	grabber_release_sound.play()
	grabbing = false
	grabbing_slider = false
