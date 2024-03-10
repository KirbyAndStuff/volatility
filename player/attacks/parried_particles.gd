extends CharacterBody2D

func _ready():
	$parried_particles.emitting = true

func _on_timer_timeout() -> void:
	queue_free()

func _on_parried_hurtbox_area_entered(area):
	if area.is_in_group("enemy_attack") and not area.is_in_group("no heal_cooldown reduction") and not area.is_in_group("no heal_cooldown reduction parry"):
		if (get_node("../player").heal_cooldown) < 100:
			(get_node("../player").heal_cooldown) += 10
			area.add_to_group("no heal_cooldown reduction parry")
