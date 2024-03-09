extends Control

@onready var healthEmitters = [$health, $health2, $health3]
@onready var parry := $parry

func _process(_delta):
	var health = (get_node("../../player").health)
	for i in range(0, healthEmitters.size()):
		healthEmitters[i].emitting = i < health

	if (get_node("../../player").parrytimer).is_stopped():
		$parry_ready.emitting = true
		$parry_ready2.emitting = true
		$parry.modulate = Color(1, 1, 1, 1)
	else:
		$parry_ready.emitting = false
		$parry_ready2.emitting = false
		$parry.modulate = Color(0, 0, 0, 0)
	if (get_node("../../player").first_weapon) == true:
		$first_weapon.color = Color(1, 1, 1, 1)
	else:
		$first_weapon.color = Color(0, 0, 0, 0.01)
	if (get_node("../../player").second_weapon) == true:
		$second_weapon.emitting = true
		$second_weapon.color = Color(1, 1, 1, 1)
	else:
		$second_weapon.color = Color(0, 0, 0, 0.01)
	var laser_cooldown = (get_node("../../player").alt_gun_cooldown)
	if laser_cooldown > 100:
		$first_weapon.lifetime = 0.5
		$first_weapon.modulate = Color(1, 1, 1)
	else:
		$first_weapon.lifetime = 0.3
		$first_weapon.modulate = Color(1, laser_cooldown / 100, laser_cooldown / 100, laser_cooldown / 100)
	var slash_cooldown = (get_node("../../player").alt_melee_cooldown)
	if slash_cooldown > 100:
		$second_weapon.explosiveness = 0
		$second_weapon.modulate = Color(1, 1, 1)
	else:
		$second_weapon.explosiveness = 0.75
		$second_weapon.modulate = Color(1, slash_cooldown / 100, slash_cooldown / 100, slash_cooldown / 100)

	var heal_cooldown = (get_node("../../player").heal_cooldown)
	var volatility = [$volatility, $volatility2,  $volatility3, $volatility4, $volatility5]

	for i in range(volatility.size()):
		if heal_cooldown >= (20 * (i + 1)):
			volatility[i].emitting = true
		else:
			volatility[i].emitting = false
			volatility[i].modulate = Color(1, 0, 0)

	if heal_cooldown >= 100:
		for vol in volatility:
			vol.modulate = Color(1, 1, 1)
