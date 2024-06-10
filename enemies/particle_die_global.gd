extends CPUParticles2D

func _ready():
	emitting = true

func die(duration):
	await get_tree().create_timer(duration, false).timeout
	queue_free()
