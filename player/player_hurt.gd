extends CPUParticles2D

func _ready():
	get_node("../camera").apply_shake(5, 0.1)
	$hurtsfx.play()
	emitting = true

func _process(_delta):
	if !emitting:
		queue_free()
