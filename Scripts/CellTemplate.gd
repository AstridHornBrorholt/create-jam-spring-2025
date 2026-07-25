class_name CellTemplate

var pos: Vector2i
var type: Cell.Type

func equals(other:CellTemplate) -> bool:
	return self.pos == other.pos and self.type == other.type

func _init(x: int, y: int, type: Cell.Type) -> void:
	self.pos = Vector2i(x, y)
	self.type = type

func duplicate() -> CellTemplate:
	return CellTemplate.new(pos.x, pos.y, type)
