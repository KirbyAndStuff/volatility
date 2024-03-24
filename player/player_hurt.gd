extends CPUParticles2D

func _ready():
	get_node("../camera").apply_shake(5, 0.1)
	emitting = true
	await get_tree().create_timer(0.5, false).timeout
	queue_free()
