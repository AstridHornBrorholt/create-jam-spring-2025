extends Node2D
class_name LevelOption

enum RewardType { Create, Modify, Destroy }

var score_goal = 100
var time_limit = 90 
var reward_type:RewardType = RewardType.Create
@onready var map:Map = $"Map Transform/Map"

@onready var reward_indicator = $"RewardIndicator"
@onready var level_info:RichTextLabel = $"Level info"
@onready var original_level_info:String = level_info.text

func initialize(reward_type:RewardType, new_map:Map, score_goal, time_limit):
	self.score_goal = score_goal
	self.time_limit = time_limit
	self.reward_type = reward_type
	
	var map_parent = map.get_parent()
	add_child(new_map)
	new_map.reparent(map_parent)
	new_map.position = map.position
	new_map.scale = map.scale
	map.queue_free()
	map = new_map
	
	reward_indicator.set_reward_type(reward_type)
	
	level_info.text = original_level_info
	level_info.text = level_info.text.replace("###", str(score_goal))
	
	
	var _time = time_limit
	_time = max(_time, 0)
	var minutes: int = floor(_time/60)
	_time -= minutes*60
	var seconds: int = floor(_time)
	_time -= seconds
	var milliseconds: int = round(_time*1e3)
	_time -= milliseconds

	var ftime = ("%02.0f" % minutes + ":" + 
				 "%02.0f" % seconds + "." + 
				 "%03.0f" % milliseconds)
	
	level_info.text = level_info.text.replace("??:??:???", ftime)

func _ready() -> void:
	var reward = [RewardType.Create, RewardType.Modify, RewardType.Destroy].pick_random()
	reward = RewardType.Create # The others are unsupported as of now.
	var map = MapSelector.get_random_map(0.5)
	var base_score = CurrentRun.get_level()[0]
	var base_time = CurrentRun.get_level()[1]
	var score:int = round(base_score*randf_range(0.7, 1.3))
	score = snapped(score, 10)
	var time:int = round(base_time*randf_range(0.9, 1.1))
	time = snapped(time, 5)
	initialize(reward, map, score, time)
