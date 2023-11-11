extends Camera2D

func _physics_process(delta: float) -> void:
	position.x = get_node("../player").position.x
	position.y = get_node("../player").position.y
