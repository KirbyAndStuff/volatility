extends CPUParticles2D

var spawn_green := preload("res://enemies/green/green.tscn")
var can_fire_laser = true
@export var event = "0"

func spawn_enemy():
	emitting = false
	await get_tree().create_timer(1, false).timeout
	var effect := spawn_green.instantiate()
	effect.position = position
	effect.add_to_group(event)
	effect.can_fire_laser = can_fire_laser
	get_parent().call_deferred("add_child", effect)
	queue_free()
