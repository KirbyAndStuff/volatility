extends AudioStreamPlayer2D

func _ready():
	await finished
	queue_free()
