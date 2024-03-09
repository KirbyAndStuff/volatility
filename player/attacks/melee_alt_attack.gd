extends Area2D

var sfx := preload("res://player/attacks/melee_alt_attack_sfx.tscn")

func _ready():
	var effect := sfx.instantiate()
	effect.position = get_node("../player").position
	get_parent().add_child(effect)
	rotation = randf_range(-180, 180)
	$CPUParticles2D.emitting = true
	if get_tree().has_group("marked melee alt"):
		global_position = get_tree().get_first_node_in_group("marked melee alt").global_position
	else:
		global_position = global_position
	await get_tree().create_timer(0.2, false).timeout
	queue_free()

func _on_area_entered(area):
	if area.is_in_group("enemy_body"):
		if (get_node("../player").heal_cooldown) < 100:
			(get_node("../player").heal_cooldown) += 5
