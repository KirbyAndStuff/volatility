extends Area2D

var health = 3
var can_be_hurt = true
var barrier_hurt := preload("res://enemies/green/green_hurt.tscn")

func _process(_delta):
	if health < 1:
		$CPUParticles2D.emitting = false
		await get_tree().create_timer(1).timeout
		queue_free()
	if get_tree().has_group("enemy") or get_tree().has_group("spawn"):
		$CPUParticles2D.modulate = Color(1, 1, 1, 0.1)
		can_be_hurt = false
	else:
		$CPUParticles2D.modulate = Color(1, 1, 1, 1)
		can_be_hurt = true

func _on_area_entered(area):
	if area.name == "bullet_hurtbox" and can_be_hurt == true:
		var effect := barrier_hurt.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		$hurt.play()
		health -= 1
	if area.is_in_group("beam") and can_be_hurt == true:
		var effect := barrier_hurt.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		$hurt.play()
		health -= 2

  
