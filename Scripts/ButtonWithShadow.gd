extends Button
class_name ButtonWithShadow

@export var shadow_offset = Vector2(0, 10)
@export var shadow_color = Color("929292ff")

var shadow:RichTextLabel

func _ready() -> void:
	shadow = RichTextLabel.new()
	add_child(shadow)
	shadow.size = size
	shadow.position.x += shadow_offset.x
	shadow.position.y += shadow_offset.y
	shadow.z_index = z_index - 1
	shadow.text = text
	shadow.mouse_filter = Control.MOUSE_FILTER_PASS # Don't let the label eat the mouse clicks
	shadow.add_theme_color_override("default_color", shadow_color)
	shadow.add_theme_font_size_override("normal_font_size", get_theme_font_size("font_size"))
	shadow.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	shadow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _process(_delta: float) -> void:
	shadow.text = text
