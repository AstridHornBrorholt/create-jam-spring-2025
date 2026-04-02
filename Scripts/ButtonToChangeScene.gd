extends ButtonWithShadow
class_name ButtonToChangeScene

@export var new_scene:String
@export var start_focused:bool = false

func _ready() -> void:
	super._ready()
	if start_focused:
		grab_focus()

func _on_pressed() -> void:
	get_tree().change_scene_to_file(new_scene)
