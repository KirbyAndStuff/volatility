extends Area2D

var health = 3

func _process(_delta):
	if health < 1:
		$CPUParticles2D.emitting = false
		await get_tree().create_timer(1).timeout
		queue_free()
		

func _on_area_entered(area):
	if area.name == "bullet_hurtbox":
		health -= 1
	if area.is_in_group("beam"):
		health -= 2
