extends Camera2D

func _process(delta: float) -> void:
	position.x = get_node("../player").position.x
	position.y = get_node("../player").position.y
