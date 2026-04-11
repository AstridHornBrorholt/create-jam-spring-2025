extends Node2D
@onready var music_volume_slider:Slider = $"Music Volume Slider"
@onready var sfx_volume_slider:Slider = $"SFX Slider"
@onready var animation_speed_slider:Slider = $"Animation Speed Slider"
@onready var animation_speed_spinner:RichTextLabel = $"Animation Speed Spinner"
@onready var game_speed_slider:Slider = $"Game Speed Slider"
@onready var game_speed_spinner:RichTextLabel = $"Game Speed Spinner"

@onready var music_player:AudioStreamPlayer = $"Tetrogue-Menu"
@onready var music_player_volume = music_player.volume_linear
@onready var grabber_grab_sound:AudioStreamPlayer = $"Grab"
@onready var grabber_grab_volume = grabber_grab_sound.volume_linear
@onready var grabber_release_sound:AudioStreamPlayer = $"Release"
@onready var grabber_release_volume = grabber_release_sound.volume_linear

@onready var image_fullscreen = preload("res://Sprites/buttons/x box.png")
@onready var image_windowed = preload("res://Sprites/buttons/empty box.png")

const spin_animation = ")x(x"
const spin_rate = 0.4
var spin_progress = 0.0
var spin_index:int = 0

var grabbing:bool = false
var config:ConfigFile

func _ready() -> void:
	music_volume_slider.value = Options.get_music_volume()
	sfx_volume_slider.value = Options.get_sfx_volume()
	animation_speed_slider.value = Options.get_animation_speed()
	game_speed_slider.value = Options.get_game_speed()
	animation_speed_spinner.text = ""
	game_speed_spinner.text = ""

func _process(delta: float) -> void:
	var spin = false
	var spinner = null
	var value = null
	
	if animation_speed_slider.has_focus():
		spin = true
		spinner = animation_speed_spinner
		value = Options.get_animation_speed()
	else:
		animation_speed_spinner.text = ""
		
	if game_speed_slider.has_focus():
		spin = true
		spinner = game_speed_spinner
		value = Options.get_game_speed()
	else:
		game_speed_spinner.text = ""
	
	if spin:
		spin_progress += delta*value
		if spin_progress > spin_rate:
			spin_progress = 0
			spin_index = (spin_index + 1)%len(spin_animation)
		spinner.text = str(value) + " " + spin_animation[spin_index]
	

func _on_music_volume_slider_drag_started() -> void:
	grabber_grab_sound.play()
	grabbing = true

func _on_music_volume_slider_value_changed(value: float) -> void:
	music_player.volume_linear = music_player_volume*value
	Options.set_music_volume(value)
	if not grabbing:
		grabber_release_sound.play()

func _on_music_volume_slider_drag_ended(_value_changed: bool) -> void:
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

func _on_sfx_slider_drag_ended(_value_changed: bool) -> void:
	grabber_release_sound.play()
	grabbing = false

func _on_animation_speed_slider_value_changed(value: float) -> void:
	Options.set_animation_speed(value)
	if not grabbing:
		grabber_release_sound.play()

func _on_animation_speed_slider_drag_started() -> void:
	grabber_grab_sound.play()
	grabbing = true


func _on_animation_speed_slider_drag_ended(_value_changed: bool) -> void:
	grabber_release_sound.play()
	grabbing = false


func _on_game_speed_slider_drag_started() -> void:
	grabber_grab_sound.play()
	grabbing = true


func _on_game_speed_slider_drag_ended(_value_changed: bool) -> void:
	grabber_release_sound.play()
	grabbing = false

func _on_game_speed_slider_value_changed(value: float) -> void:
	Options.set_game_speed(value)
	if not grabbing:
		grabber_release_sound.play()


func _on_fullscreen_button_pressed() -> void:
	if is_fullscreen_mode_active():
		$"Full Screen Button".texture_normal = image_windowed
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		$"Full Screen Button".texture_normal = image_fullscreen
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		
func is_fullscreen_mode_active():
	var mode = DisplayServer.window_get_mode()
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		return true
	if mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		return true
	return false
