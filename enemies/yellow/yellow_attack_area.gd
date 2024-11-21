extends CPUParticles2D

func _ready():
	var tween = create_tween()
	tween.tween_property($attack_area_hurtbox/CollisionShape2D, "scale", Vector2(258, 258), 0.75)

func _process(_delta):
	if not get_tree().has_group("yellow"):
		emitting = false
		$attack_area_hurtbox/CollisionShape2D.disabled = true
		await get_tree().create_timer(1, false).timeout
		queue_free()

func _on_timer_timeout() -> void:
	emitting = false
	$attack_area_hurtbox/CollisionShape2D.disabled = true
	await get_tree().create_timer(1, false).timeout
	queue_free()
