extends Node2D

@onready var animation_speed = Options.get_animation_speed()

@onready var level_label:RichTextLabel = $"Level"
@onready var target_label:RichTextLabel = $"Target"
@onready var time_label:RichTextLabel = $"Time"
@onready var boss_level_label:RichTextLabel = $"Boss Level"
@onready var boss_type_label:RichTextLabel = $"Boss Type"
@onready var begin_button:Button = $"Interactive/BeginButton"

func _ready() -> void:
	begin_button.grab_focus()
	var win_level = CurrentRun.game_mode.win_level
	var score_target = CurrentRun.next_score_goal
	var time = CurrentRun.next_time_limit
	var minutes:int = floor(time/60.)
	var seconds:int = time - minutes*60
	
	# This totally hijacks and repurposes the text labels. Maybe I should have made a different screen but this seemed easier at the time.
	if CurrentRun.level == CurrentRun.next_boss_level:
		level_label.text = "[color=red]Boss Level[/color]"
		level_label.add_theme_font_size_override("normal_font_size", 280)
		replace_text(target_label, "###", score_target)
		replace_text(time_label, "??.??.??", str(minutes) + ":" + str(seconds))
		boss_level_label.text = "\n[color=blue]Level " + str(CurrentRun.level) + "[/color]"
		boss_level_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		boss_type_label.text = "\n[color=red]" + Boss.get_description(CurrentRun.next_boss) + "[/color]"
		boss_type_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		boss_type_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	else:
		replace_text(level_label, "??", CurrentRun.level)
		replace_text(level_label, "##", win_level)
		replace_text(target_label, "###", score_target)
		replace_text(time_label, "??.??.??", str(minutes) + ":" + str(seconds))
		replace_text(boss_level_label, "??", CurrentRun.next_boss_level)
		replace_text(boss_type_label, "##", Boss.get_description(CurrentRun.next_boss))
		
		level_label.visible = false
		target_label.visible = false
		time_label.visible = false
		boss_level_label.visible = false
		boss_type_label.visible = false
		
		await get_tree().create_timer(0.5/animation_speed).timeout
		level_label.visible = true
		await get_tree().create_timer(1/animation_speed).timeout
		target_label.visible = true
		await get_tree().create_timer(0.5/animation_speed).timeout
		time_label.visible = true
		await get_tree().create_timer(0.5/animation_speed).timeout
		boss_level_label.visible = true
		await get_tree().create_timer(0.5/animation_speed).timeout
		boss_type_label.visible = true

func replace_text(label:RichTextLabel, what, forwhat):
	label.text = label.text.replace(what, str(forwhat))

func _on_begin_button_button_down() -> void:
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")
