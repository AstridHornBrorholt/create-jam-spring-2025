extends Node2D
class_name LevelOption

enum RewardType { Create, Modify, Destroy, Nothing }

var score_goal = 100
var time_limit = 90 
var reward_type:RewardType = RewardType.Create
@onready var level = $"Level"
@onready var map:Map = $"Level/Map Transform/Map"
@onready var reward_indicator = $"Level/RewardIndicator"
@onready var level_info:RichTextLabel = $"Level/Level info"
@onready var original_level_info:String = level_info.text
@onready var select_button:Button = $"SelectButton"

var on_select:Callable

var focused = false

var scale_focus = Vector2.ONE
@onready var scale_no_focus = level.transform.get_scale()

var color_focus = Color("#ffffffff")
@onready var color_no_focus = level.modulate

# Animation
var focus_progress:float = 0.0
const focus_rate = 6.0

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
	if reward_type == RewardType.Nothing:
		level_info.text = level_info.text.replace("Reward:", "")
	
	if time_limit != INF:
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
	else:
		level_info.text = level_info.text.replace("??:??:???", "plenty")

func _ready() -> void:
	
	var reward = pick_random_reward()
	
	var map = MapSelector.get_random_map(0.5)
	var base_score = CurrentRun.get_level()[0]
	var base_time = CurrentRun.get_level()[1]
	var score:int = round(base_score*randf_range(0.7, 1.3))
	score = snapped(score, 10)
	var time:float = roundf(base_time*randf_range(0.9, 1.1))
	time = snappedf(time, 5)
	initialize(reward, map, score, time)

func _process(delta: float) -> void:
	if !focused:
		level.modulate = color_no_focus
		level.scale = scale_focus
		return
	
	focus_progress += delta*focus_rate
	focus_progress = min(focus_progress, 1)
	level.scale = lerp(scale_no_focus, scale_focus, focus_progress)
	level.modulate = color_focus

func pick_random_reward() -> RewardType:
	if CurrentRun.stash.size() == 1:
		return RewardType.Create
	else:
		return [
			RewardType.Create, 
			#RewardType.Modify, # Not implemented
			RewardType.Destroy
			].pick_random()


func _on_select_button_focus_entered() -> void:
	focus_progress = 0
	focused = true

func _on_select_button_focus_exited() -> void:
	focused = false

func _on_select_button_mouse_entered() -> void:
	select_button.grab_focus()


func _on_select_button_button_down() -> void:
	on_select.call(self)
