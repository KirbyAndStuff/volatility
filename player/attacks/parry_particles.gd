extends CPUParticles2D

func _ready():
	emitting = true
	await get_tree().create_timer(0.2, false).timeout
	queue_free()
