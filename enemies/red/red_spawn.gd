extends CPUParticles2D

var spawn_red := preload("res://enemies/red/red.tscn")

func _ready():
	await get_tree().create_timer(1).timeout
	$Area2D/CollisionShape2D.disabled = false

func _on_area_2d_area_entered(area):
	if area.is_in_group("player"):
		emitting = false
		await get_tree().create_timer(1).timeout
		var effect := spawn_red.instantiate()
		effect.position = position
		get_parent().call_deferred("add_child", effect)
		queue_free()
