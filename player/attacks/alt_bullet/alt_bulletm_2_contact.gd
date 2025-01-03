extends RayCast2D

var shot = false

func _ready():
	await get_tree().create_timer(0.1, false).timeout
	create_tween().tween_property($Line2D, "width", 0, 0.5)
	await get_tree().create_timer(0.1, false).timeout
	shot = true

func _physics_process(_delta: float) -> void:
	if is_colliding() and shot == false:
		target_position = to_local(get_collision_point()) + Vector2(1000, 0)
		$Line2D.points[1] = target_position - Vector2(1000, 0)
	elif shot == false:
		$Line2D.points[1] = Vector2(2000, 0)
		shot = true

func _on_timer_timeout() -> void:
	queue_free()
