extends CharacterBody2D

var direction := Vector2.ZERO
var bullet_death := preload("res://player/attacks/alt_bullet/alt_bullet_death.tscn")
var detonation := preload("res://player/attacks/bullet/beam_detonation.tscn")
var charged_sfx := preload("res://player/attacks/alt_bullet/alt_bullet_charged_sfx.tscn")
var m2_contact := preload("res://player/attacks/alt_bullet/alt_bulletm_2_contact.tscn")
var m2_contactsfx := preload("res://player/attacks/alt_bullet/alt_bulletm_2_contactsfx.tscn")
var speed = 2500.0
var drain_speed = true
var come_back = false
var hit_wall = false
var enemies_hit = 0
var damage = 1
var in_beam = false
var charged = false
var charges = 0
var closest_distance = INF
var closest_enemy = null
var closest_bullet = null
var bulletm2_angle_min = -0.2
var bulletm2_angle_max = -0.15

@onready var blades = [$blade, $blade2, $blade3, $blade4]

func _ready():
	scale = Vector2(0.2, 0.2)
	create_tween().tween_property(self, "scale", Vector2(1, 1), 0.2)

func shoot(from: Vector2, to: Vector2):
	global_position = from
	direction = from.direction_to(to)
	rotation = direction.angle()

func _physics_process(delta):
	position += direction * speed * delta
	if drain_speed:
		speed -= 5000.0 * delta
	else:
		speed += 5000.0 * delta
	if speed < 0 and drain_speed:
		drain_speed = false
		come_back = true
		$player_death/CollisionShape2D.disabled = false
		$hurtbox.add_to_group("parryable")
	if come_back:
		direction = global_position.direction_to(get_node("../player").position)
	if in_beam:
		if come_back:
			speed -= 4000.0 * delta
		else:
			speed += 4000.0 * delta
	$stop_follow_player.scale = Vector2(speed, speed) / 2500.0

func _on_hurtbox_area_entered(area):
	if area.is_in_group("enemy_body"):
		if not area.is_in_group("no heal_cooldown reduction") and area.get_parent().guarded == false:
			get_node("../player").add_heal_cooldown(5)
		enemies_hit += 1
		if 2 < enemies_hit and not is_in_group("parried"):
			die()
	if area.is_in_group("beam") and not is_in_group("parried"):
		in_beam = true
		if charged == false:
			charged = true
			charges = 4
			var effect := charged_sfx.instantiate()
			effect.position = position
			get_parent().add_child(effect)
			for vol in blades:
				vol.modulate = Color(1, 3, 3, 1)
	if area.is_in_group("parry") and not is_in_group("parried"):
		come_back = false
		$Timer.start()
		$player_death.monitoring = false
		$body.modulate = Color(0, 1, 1, 1)
		$flames.modulate = Color(0, 1, 1, 1)
		add_to_group("parried")
		speed += 2500.0
		shoot(global_position, get_global_mouse_position())
	if area.is_in_group("enemy") and is_in_group("parried"):
		die()

func _on_player_death_area_entered(area):
	if area.is_in_group("player") and get_node("../player").amount_of_i_frames < 1:
		die()

func _on_hurtbox_body_entered(body):
	if body.is_in_group("wall") and hit_wall == false:
		hit_wall = true
		die()

func die():
	if is_in_group("parried"):
		var effect := detonation.instantiate()
		effect.position = position
		get_parent().call_deferred("add_child", effect)
	else:
		var effect := bullet_death.instantiate()
		effect.position = $body.global_position
		if charges > 0:
			effect.modulate = Color(0, 1, 1, 1)
		get_parent().add_child(effect)
	queue_free()

func _on_timer_timeout():
	die()

func _on_hurtbox_area_exited(area):
	if area.is_in_group("beam"):
		in_beam = false

func _on_stop_follow_player_area_entered(area):
	if area.is_in_group("player"):
		come_back = false

func _on_stop_follow_player_area_exited(area):
	if area.is_in_group("player") and not is_in_group("parried") and scale == Vector2(1, 1):
		come_back = false
		drain_speed = true
		if speed > 1500.0:
			speed = 1500.0
		enemies_hit = 0
		await get_tree().create_timer(0.001, false).timeout
		if charges > 0:
			charges -= 1
			blades[charges].modulate = Color(1, 1, 1, 1)
			if charges < 1:
				for vol in blades:
					create_tween().tween_property(vol, "modulate", Color(1, 1, 1, 0), 0.25)
			var bullet_scene = preload("res://player/attacks/bullet/bulletm2.tscn")
			var shot = bullet_scene.instantiate()
			shot.shake = 10
			shot.remove_from_groupa = true
			shot.hit_from_inside = false
			#if get_tree().has_group("bullet"):
				#where_laser_hit_bullet()
				#shot.shoot(global_position, closest_bullet.global_position)
			if get_tree().has_group("enemy_body"):
				where_laser_hit_enemy()
				shot.shoot(global_position, closest_enemy.global_position)
			else:
				shot.shoot(global_position, Vector2(global_position.x + randf_range(-1000, 1000), global_position.y + randf_range(-1000, 1000)))
			get_parent().call_deferred("add_child", shot)
		elif charged == false:
			var bullet_scene = preload("res://player/attacks/alt_bullet/alt_bullet_dodge.tscn")
			var shot = bullet_scene.instantiate() 
			shot.modulate = Color(2.5, 2.5, 2.5, 1)
			if get_tree().has_group("enemy_body"):
				where_laser_hit_enemy()
				shot.shoot(global_position, closest_enemy.global_position)
			else:
				shot.shoot(global_position, Vector2(global_position.x + randf_range(-1000, 1000), global_position.y + randf_range(-1000, 1000)))
			get_parent().call_deferred("add_child", shot)

func where_laser_hit_bullet():
	var all_bullets = get_tree().get_nodes_in_group("bullet")
	if all_bullets.size() > 0:
		closest_bullet = all_bullets[0]
		for bullet in all_bullets:
			var distance_to_this_bullet = global_position.distance_squared_to(bullet.global_position)
			var distance_to_closest_bullet = global_position.distance_squared_to(closest_bullet.global_position)
			if distance_to_this_bullet < distance_to_closest_bullet:
				closest_bullet = bullet
	return closest_bullet

func where_laser_hit_enemy():
	var all_enemies = get_tree().get_nodes_in_group("enemy_body")
	if all_enemies.size() > 0:
		closest_enemy = all_enemies[0]
		for enemy in all_enemies:
			var distance_to_this_enemy = global_position.distance_squared_to(enemy.global_position)
			var distance_to_closest_enemy = global_position.distance_squared_to(closest_enemy.global_position)
			if distance_to_this_enemy < distance_to_closest_enemy:
				closest_enemy = enemy
	return closest_enemy

func _on_detect_m_2_area_entered(area):
	if area.is_in_group("bulletm2"):
		if charged and charges > 0:
			bulletm2_angle_min = -0.5
			bulletm2_angle_max = -0.4
			var sfxeffect := m2_contactsfx.instantiate()
			sfxeffect.position = position
			sfxeffect.pitch_scale = 0.6
			sfxeffect.volume_db = 10
			add_sibling(sfxeffect)
			for i in range(8):
				var effect := m2_contact.instantiate()
				effect.position = position
				effect.scale = Vector2(2, 2)
				effect.rotation = area.get_parent().directiona.angle() + randf_range(bulletm2_angle_min, bulletm2_angle_max)
				bulletm2_angle_min += 0.1
				bulletm2_angle_max += 0.1
				add_sibling(effect)
		if charged == false:
			var sfxeffect := m2_contactsfx.instantiate()
			sfxeffect.position = area.get_parent().position
			add_sibling(sfxeffect)
			for i in range(4):
				var effect := m2_contact.instantiate()
				effect.position = area.get_parent().position
				effect.rotation = area.get_parent().directiona.angle() + randf_range(bulletm2_angle_min, bulletm2_angle_max)
				bulletm2_angle_min += 0.1
				bulletm2_angle_max += 0.1
				add_sibling(effect)
		queue_free()
