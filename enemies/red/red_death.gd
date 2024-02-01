extends CPUParticles2D

func _ready():
	$deathsfx.play()
	emitting = true
	$"left eye".emitting = true
	$"right eye".emitting = true

func _process(_delta):
	if !emitting:
		queue_free()
