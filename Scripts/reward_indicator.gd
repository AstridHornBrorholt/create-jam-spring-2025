extends Node2D
class_name RewardIndicator


@onready var icon = $"Wiggler/Icon"
@onready var label = $"Label"
@onready var wiggler = $"Wiggler"

var create_icon:Texture2D = preload("res://Sprites/Create.png")
var modify_icon:Texture2D = preload("res://Sprites/ModifyIcon.png")
var destroy_icon:Texture2D = preload("res://Sprites/Destroy.png")

func set_wiggle(state:bool):
	wiggler.wiggle = state

func set_reward_type(reward_type:LevelOption.RewardType):
	match reward_type:
		LevelOption.RewardType.Create:
			icon.texture = create_icon
			label.text = "Create"
		LevelOption.RewardType.Modify:
			icon.texture = modify_icon
			label.text = "Modify"
		LevelOption.RewardType.Destroy:
			icon.texture = destroy_icon
			label.text = "Destroy"
