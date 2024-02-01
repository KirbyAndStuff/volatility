extends CPUParticles2D

func _ready():
	$hurtsfx.play()
	emitting = true

func _process(_delta):
	if !emitting:
		queue_free()
