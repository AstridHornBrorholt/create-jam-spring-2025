# This is the options singleton global thingy
extends Node

var config:ConfigFile
const OPTIONS_FILE = "user://options.cfg"
const OPTIONS_VERSION = "🐬"

func _ready() -> void:
	config = load_or_create_config()
	set_volume_levels()
	# No signal emitted on scene change. Have to detect ourselves
	# https://www.reddit.com/r/godot/comments/iwwhsh/signal_for_scene_change/
	get_tree().connect("node_added", Callable(self, "_on_node_added"))

func _on_node_added(new_node:Node):
	if new_node.get_parent() == get_tree().root:
		on_scene_change()

func on_scene_change():
	set_volume_levels()

# Recursion through entire tree, finding AudioStreamPlayers and adjusting their volume
func set_volume_levels(tree:Node=get_tree().root):
	if tree.name == "OptionsMenu":
		return # The OptionsMenu has special handling of volume to update levels live.
	for node in tree.get_children():
		set_volume_levels(node)
		if not node is AudioStreamPlayer:
			continue
		var asp:AudioStreamPlayer = node
		# Mainmatter. If audio is set to autoplay, I conclude it's background music.
		if asp.autoplay:
			asp.volume_linear *= get_music_volume()
		else:
			asp.volume_linear *= get_sfx_volume()

func load_or_create_config() -> ConfigFile:
	var config:ConfigFile = ConfigFile.new()
	var load_result = config.load(OPTIONS_FILE)
	
	if config.get_value("Options", "Version") != OPTIONS_VERSION:
		config = ConfigFile.new()
		print("Resetting options")
		config.set_value("Options", "Version", OPTIONS_VERSION)
		config.set_value("Volume", "Music", 1.)
		config.set_value("Volume", "SFX", 1.)
		config.set_value("Gameplay", "AnimationSpeed", 1.)
		config.set_value("Gameplay", "GameSpeed", 1.)
		config.set_value("Menus", "LastGameMode", 4)
		config.save(OPTIONS_FILE)
	
	return config

func set_music_volume(value:float):
	config.set_value("Volume", "Music", value)
	return config.save(OPTIONS_FILE)

func get_music_volume() -> float:
	return config.get_value("Volume", "Music")

func set_sfx_volume(value:float):
	config.set_value("Volume", "SFX", value)
	return config.save(OPTIONS_FILE)

func get_sfx_volume() -> float:
	return config.get_value("Volume", "SFX")

func set_animation_speed(value:float):
	config.set_value("Gameplay", "AnimationSpeed", value)
	return config.save(OPTIONS_FILE)

func get_animation_speed() -> float:
	return config.get_value("Gameplay", "AnimationSpeed")
	
func set_game_speed(value:float):
	config.set_value("Gameplay", "GameSpeed", value)
	return config.save(OPTIONS_FILE)

func get_game_speed() -> float:
	var v =  config.get_value("Gameplay", "GameSpeed")
	return v
	
func set_last_game_mode(value:int) -> void:
	config.set_value("Menus", "LastGameMode", value)
	return config.save(OPTIONS_FILE)

func get_last_game_mode() -> int:
	return config.get_value("Menus", "LastGameMode", 4)
