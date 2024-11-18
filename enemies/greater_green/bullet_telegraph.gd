extends Line2D

func _ready():
	create_tween().tween_property(self, "modulate", Color(0, 1, 0, 0), 0.5)
	await get_tree().create_timer(0.5, false).timeout
	queue_free()
