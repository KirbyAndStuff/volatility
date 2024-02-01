extends CPUParticles2D

func _ready():
	$deathsfx.play()
	emitting = true

func _process(_delta):
	if !emitting:
		queue_free()
