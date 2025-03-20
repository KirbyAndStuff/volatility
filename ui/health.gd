extends Control

@onready var healthEmitters = [$health, $health2, $health3]
@onready var volatility = [$volatility, $volatility2,  $volatility3, $volatility4, $volatility5]
@onready var parry = $parry

func _ready() -> void:
	position = Vector2(126, 932)
	get_node("../../player").connect("is_speed_boosted", change_speed_boost)
	get_node("../../player").connect("changed_weapon", change_weapon_visible)

func _process(_delta):
	var health = (get_node("../../player").health)
	for i in range(0, healthEmitters.size()):
		healthEmitters[i].emitting = i < health

	var parry_cooldown = get_node("../../player").parry_cooldown
	if parry_cooldown >= 30:
		if $parry_ready.emitting == false:
			$parry_ready.emitting = true
			$parry_ready2.emitting = true
		$parry.modulate = Color(1, 1, 1, 1)
	else:
		if $parry_ready.emitting == true:
			$parry_ready.emitting = false
			$parry_ready2.emitting = false
		$parry.modulate = Color(1, parry_cooldown / 30, parry_cooldown / 30, parry_cooldown / 30)

	var gunm2_cooldown = (get_node("../../player").gunm2_cooldown)
	if gunm2_cooldown >= 100:
		$first_weapon.lifetime = 0.5
		$first_weapon.modulate = Color(1, 1, 1)
	else:
		$first_weapon.lifetime = 0.3
		$first_weapon.modulate = Color(1, gunm2_cooldown / 100, gunm2_cooldown / 100, gunm2_cooldown / 100)

	var laser_cooldown = (get_node("../../player").alt_gunm2_cooldown)
	if laser_cooldown >= 100:
		$first_alt/flames.lifetime = 0.5
		$first_alt.modulate = Color(1, 1, 1)
	else:
		$first_alt/flames.lifetime = 0.25
		$first_alt.modulate = Color(1, laser_cooldown / 100, laser_cooldown / 100, laser_cooldown / 100)

	var slash_cooldown = (get_node("../../player").meleem2_cooldown)
	if slash_cooldown >= 100:
		$second_weapon.explosiveness = 0
		$second_weapon.modulate = Color(1, 1, 1)
	else:
		$second_weapon.explosiveness = 0.75
		$second_weapon.color = Color(1, slash_cooldown / 100, slash_cooldown / 100, slash_cooldown / 100)

	var heal_cooldown = (get_node("../../player").heal_cooldown)

	for i in range(volatility.size()):
		if heal_cooldown >= (20 * (i + 1)):
			volatility[i].emitting = true
		else:
			volatility[i].emitting = false
			volatility[i].modulate = Color(1, 0, 0)

	if heal_cooldown >= 100:
		for vol in volatility:
			vol.modulate = Color(1, 1, 1)

func change_speed_boost(value):
	if value == 300:
		$parry.color = Color(0, 1, 1, 1)
	if value == 0:
		$parry.color = Color(1, 1, 1, 1)

func change_weapon_visible(value):
	$first_weapon.visible = (value == "bullet")
	$first_alt.visible = (value == "alt_bullet")
	$second_weapon.visible = (value == "melee")
