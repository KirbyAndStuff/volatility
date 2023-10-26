extends CPUParticles2D

func _ready():
	emitting = true
	$"left eye".emitting = true
	$"right eye".emitting = true
	
func _process(delta):
	if !emitting:
		queue_free()
