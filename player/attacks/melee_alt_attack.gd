extends Area2D

func _ready():
	rotation = randf_range(-180, 180)
	$CPUParticles2D.emitting = true
	if get_tree().has_group("marked"):
		global_position = get_tree().get_first_node_in_group("marked").global_position
	else:
		global_position = global_position
	await get_tree().create_timer(0.2).timeout
	queue_free()
