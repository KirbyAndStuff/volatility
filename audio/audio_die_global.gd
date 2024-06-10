extends AudioStreamPlayer2D

func die(duration):
	await get_tree().create_timer(duration, false).timeout
	queue_free()
