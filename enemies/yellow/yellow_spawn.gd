extends CPUParticles2D

var spawn_yellow := preload("res://enemies/yellow/yellow.tscn")
@export var event = "0"

func spawn_enemy():
	emitting = false
	await get_tree().create_timer(1, false).timeout
	var effect := spawn_yellow.instantiate()
	effect.position = position
	effect.add_to_group(event)
	get_parent().call_deferred("add_child", effect)
	queue_free()
