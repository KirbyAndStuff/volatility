extends CPUParticles2D

var spawn_purple := preload("res://enemies/purple/purple.tscn")

func _on_area_2d_area_entered(area):
	if area.is_in_group("player"):
		emitting = false
		await get_tree().create_timer(1, false).timeout
		var effect := spawn_purple.instantiate()
		effect.position = position
		get_parent().call_deferred("add_child", effect)
		queue_free()

func _on_wall_check_body_entered(body):
	if body.is_in_group("wall"):
		get_parent().give_credit = true
		queue_free()

func _ready():
	await get_tree().create_timer(0.25, false).timeout
	visible = true
	await get_tree().create_timer(1, false).timeout
	$Area2D/CollisionShape2D.disabled = false
