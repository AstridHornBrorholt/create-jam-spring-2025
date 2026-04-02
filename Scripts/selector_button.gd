extends ButtonWithShadow

@onready var run_state:RunState = CurrentRun
@onready var selection_option:SelectionOption = $".."

func _on_pressed() -> void:
	#Add reward to stash
	run_state.stash.push_back(selection_option.tetriminos.template)
	selection_option.picked = true
	self.visible = false
	selection_option.selector.register_picked(selection_option.id)
