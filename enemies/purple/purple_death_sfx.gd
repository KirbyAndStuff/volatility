extends AudioStreamPlayer2D

func _ready():
	await get_tree().create_timer(1.2, false).timeout
	queue_free()
