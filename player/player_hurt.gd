extends CPUParticles2D

func _ready():
	$hurtsfx.play()
	emitting = true
	await get_tree().create_timer(0.1, false).timeout
	remove_from_group("screen_shake 5")

func _process(_delta):
	if !emitting:
		queue_free()
