extends Area2D

func _on_area_entered(area):
	if area.is_in_group("player"):
		await get_tree().create_timer(2, false).timeout
		$CPUParticles2D.speed_scale = 0.5
		$CPUParticles2D.emitting = false
