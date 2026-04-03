extends TileMapLayer

func _ready() -> void:
	self_modulate = CurrentRun.game_mode.border_color
