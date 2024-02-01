extends AudioStreamPlayer2D

func _ready():
	playing = true

func _process(_delta):
	if !playing:
		queue_free()
