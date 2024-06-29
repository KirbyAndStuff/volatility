extends CharacterBody2D

var parried = false

func _ready():
	$parried_particles.emitting = true

func _process(_delta):
	if parried and $parried_hurtbox.monitoring == true:
		$parried_hurtbox.monitoring = false
		$parried_hurtbox.monitorable = false

func _on_timer_timeout() -> void:
	queue_free()

func _on_parried_hurtbox_area_entered(area):
	if area.is_in_group("parryable"):
		if area.is_in_group("enemy_attack"):
			if (get_node("../player").heal_cooldown) < 100 and not area.is_in_group("no heal_cooldown reduction") and not area.is_in_group("no heal_cooldown reduction parry"):
				(get_node("../player").heal_cooldown) = clamp((get_node("../player").heal_cooldown) + 10, 0, 100)
				area.add_to_group("no heal_cooldown reduction parry")
		parried = true
