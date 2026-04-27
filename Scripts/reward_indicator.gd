extends Node2D
class_name RewardIndicator

@export var type:LevelOption.RewardType = LevelOption.RewardType.Create
@export var wiggle:bool = true

@onready var icon = $"Wiggler/Icon"
@onready var label = $"Label"
@onready var wiggler = $"Wiggler"

var create_icon:Texture2D = preload("res://Sprites/Create.png")
var modify_icon:Texture2D = preload("res://Sprites/ModifyIcon.png")
var destroy_icon:Texture2D = preload("res://Sprites/Destroy.png")

func _ready() -> void:
	set_reward_type(self.type)
	set_wiggle(self.wiggle)

func set_wiggle(state:bool):
	self.wiggle = state
	wiggler.wiggle = state

func set_reward_type(reward_type:LevelOption.RewardType):
	self.type = reward_type
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
		LevelOption.RewardType.Nothing:
			icon.texture = null
			label.text = ""
