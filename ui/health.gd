extends Control

@onready var healthEmitters = [$health, $health2, $health3]
@onready var parry = $parry
@onready var weapons = [$first_weapon, $second_weapon]
@onready var alt_weapons = [$first_alt, $CPUParticles2D]

func _process(_delta):
	var health = (get_node("../../player").health)
	for i in range(0, healthEmitters.size()):
		healthEmitters[i].emitting = i < health

	if get_node("../../player").speed_boost == 300 and not $parry.color == Color(0, 1, 1, 1):
		$parry.color = Color(0, 1, 1, 1)
	if get_node("../../player").speed_boost == 0 and not $parry.color == Color(1, 1, 1, 1):
		$parry.color = Color(1, 1, 1, 1)

	var parry_cooldown = get_node("../../player").parry_cooldown
	if parry_cooldown > 30:
		$parry_ready.emitting = true
		$parry_ready2.emitting = true
		$parry.modulate = Color(1, 1, 1, 1)
	else:
		if $parry_ready.emitting == true:
			$parry_ready.emitting = false
			$parry_ready2.emitting = false
		$parry.modulate = Color(1, parry_cooldown / 30, parry_cooldown / 30, parry_cooldown / 30)

	for i in range(weapons.size()):
		update_weapon_color(weapons[i], (get_node("../../player").active_weapon) == i + 1)

	var laser_cooldown = (get_node("../../player").gunm2_cooldown)
	if laser_cooldown > 100:
		if (get_node("../../player").variant_weapon) == false:
			$first_weapon.lifetime = 0.5
			$first_weapon.modulate = Color(1, 1, 1)
			$first_alt.modulate = Color(0, 0, 0, 0)
		elif (get_node("../../player").active_weapon) == 1:
			$first_alt/flames.lifetime = 0.5
			$first_alt.modulate = Color(1, 1, 1)
			$first_weapon.modulate = Color(0, 0, 0, 0)
	else:
		if (get_node("../../player").variant_weapon) == false:
			$first_weapon.lifetime = 0.3
			$first_weapon.modulate = Color(1, laser_cooldown / 100, laser_cooldown / 100, laser_cooldown / 100)
			$first_alt.modulate = Color(0, 0, 0, 0)
		elif (get_node("../../player").active_weapon) == 1:
			$first_alt/flames.lifetime = 0.25
			$first_alt.modulate = Color(1, laser_cooldown / 100, laser_cooldown / 100, laser_cooldown / 100)
			$first_weapon.modulate = Color(0, 0, 0, 0)

	var slash_cooldown = (get_node("../../player").meleem2_cooldown)
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

func update_weapon_color(weapon_node, is_active):
	if is_active and not weapon_node.color == Color(1, 1, 1, 1):
		weapon_node.color = Color(1, 1, 1, 1)
	elif not is_active and not weapon_node.color == Color(0, 0, 0, 0):
		weapon_node.color = Color(0, 0, 0, 0)
