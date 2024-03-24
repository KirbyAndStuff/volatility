extends CPUParticles2D

func _ready():
	emitting = true
	await get_tree().create_timer(1, false).timeout
	queue_free()
