extends CharacterBody2D

var dash_particles := preload("res://player/player_dash_particles.tscn")
var parry_particles := preload("res://player/attacks/parry/parry_particles.tscn")
var parried_particles := preload("res://player/attacks/parry/parried_particles.tscn")
var player_hurt := preload("res://player/player_hurt.tscn")
var player_death := preload("res://player/player_death.tscn")
var bullet_explosion := preload("res://player/attacks/bullet/bullet_explosion.tscn")
var alt_bullet_explosion := preload("res://player/attacks/alt_bullet/alt_bullet_explosion.tscn")
var player_land := preload("res://player/player_land.tscn")

var health = 3
var speed = 700
var speed_boost = 0
var accel = 7000
var accel_boost = 0
var friction = 4000
var friction_boost = 0
var stamina = 100
var gunm2_cooldown = 100
var alt_gunm2_cooldown = 100 #aaaaaaaaaaa
var meleem2_cooldown = 100
var input = Vector2.ZERO
var is_dead = false
var stamina_tween = true
var powered_next_bullet_number = 0
var powered_next_bullet = false
var melee_order = 1
var can_scroll_up = true
var can_scroll_down = true
var amount_of_i_frames = 0
var heal_cooldown = 0
var parry_cooldown = 30
var in_intro = false
var got_hit = false
var take_damage = 0
var taken_hit = false

var bullets = ["bullet", "alt_bullet"]
var melees = ["melee"]
var weapons = ["bullet", "melee"]
var key = 0
var key_wep = 0
var active_weapon = "bullet"

func _physics_process(delta):
	player_movement(delta)
	if stamina <= 100:
		stamina += 25 * delta
	if gunm2_cooldown <= 100:
		gunm2_cooldown += 50 * delta
	if alt_gunm2_cooldown <= 100 and not get_tree().has_group("beam"): #aaaaaaaaa
		alt_gunm2_cooldown += 50 * delta #aaaaaaaa
	if meleem2_cooldown <= 100:
		meleem2_cooldown += 25 * delta
	if parry_cooldown <= 30:
		parry_cooldown += 10 * delta
	if in_intro:
		speed = 0
		$"left eye node/left eye".lifetime = 0.1
		$"right eye node/right eye".lifetime = 0.1
		position.y += 2000 * delta

func _process(_delta):
	if take_damage > 0 and amount_of_i_frames < 1 and is_dead == false:
		health -= 1
		i_frames(1)
		player_hurt_particles()
		taken_hit = true
		framefreeze(0.4, 0.3)
	if Input.is_action_pressed("dash") and stamina > 50 and $DashLength.is_stopped() and is_dead == false and in_intro == false:
		dash()
		stamina_tween = false
	if Input.is_action_pressed("parry") and parry_cooldown > 30 and is_dead == false and in_intro == false:
		parry()
	if health < 1 and is_dead == false:
		var effect := player_death.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		modulate = Color(0, 0, 0, 0)
		speed = 0
		speed_boost = 0
		$body.emitting = false
		$"left eye node/left eye".emitting = false
		$"right eye node/right eye".emitting = false
		is_dead = true
	if Input.is_action_pressed("left_mouse_button") and is_dead == false and in_intro == false:
		if active_weapon == "bullet" and $GunTimer.is_stopped() and not get_tree().has_group("beam"):
			shoot()
		if active_weapon == "alt_bullet" and $Alt_GunTimer.is_stopped() and not get_tree().has_group("bulletm2"):
			alt_shoot()
		if active_weapon == "melee" and $MeleeTimer.is_stopped() and not get_tree().has_group("meleem2"):
			melee()
	if Input.is_action_pressed("right_mouse_button") and is_dead == false and in_intro == false:
		if active_weapon == "bullet":
			shootm2()
		if active_weapon == "alt_bullet":
			alt_shootm2()
		if active_weapon == "melee":
			meleem2()
	if Input.is_action_just_pressed("first_weapon"):
		if active_weapon in bullets:
			key += 1
			if key > bullets.size() - 1:
				key = 0
			active_weapon = bullets[key]
		else:
			key = 0
			key_wep = 0
			active_weapon = weapons[key_wep]
		$switch_weaponsfx.play()
	if Input.is_action_just_pressed("second_weapon"):
		if active_weapon in melees:
			key += 1
			if key > melees.size() - 1:
				key = 0
			active_weapon = melees[key]
		else:
			key = 0
			key_wep = 1
			active_weapon = weapons[key_wep]
		$switch_weaponsfx.play()
	if Input.is_action_just_pressed("scroll_up") and can_scroll_up:
		can_scroll_up = false
		key = 0
		key_wep += 1
		if key_wep > weapons.size() - 1:
			key_wep = 0
		active_weapon = weapons[key_wep]
		$switch_weaponsfx.play()
		await get_tree().create_timer(0.2, false).timeout
		can_scroll_up = true
	if Input.is_action_just_pressed("scroll_down") and can_scroll_down:
		can_scroll_down = false
		key = 0
		key_wep += 1
		if key_wep > weapons.size() - 1:
			key_wep = 0
		active_weapon = weapons[key_wep]
		$switch_weaponsfx.play()
		await get_tree().create_timer(0.2, false).timeout
		can_scroll_down = true
	if Input.is_action_just_pressed("switch_variant"):
		key += 1
		if active_weapon in bullets:
			if key > bullets.size() - 1:
				key = 0
			active_weapon = bullets[key]
		if active_weapon in melees:
			if key > melees.size() - 1:
				key = 0
			active_weapon = melees[key]
		$switch_weaponsfx.play()
	if heal_cooldown >= 100 and health < 3 and is_dead == false:
		health += 1
		heal_particles()
		heal_cooldown = 0
	if is_dead == false:
		if get_tree().has_group("enemy") or get_tree().has_group("enemy_attack") or get_tree().has_group("spawn"):
			if $"combat eye".emitting == false:
				$"combat eye".emitting = true
				$"combat eye2".emitting = true
		elif $"combat eye".emitting == true:
			$"combat eye".emitting = false
			$"combat eye2".emitting = false
	elif  $"combat eye".emitting == true:
		$"combat eye".emitting = false
		$"combat eye2".emitting = false
	if $powered_bullet2.visible:
		$powered_bullet2.look_at(get_global_mouse_position())
	#if Input.is_action_just_pressed("switch_variant"):
		#health = 0
	#else:
		#health = 10

func get_input():
	if input.length() > 0.0:
		if $"left eye node/left eye".lifetime == 0.2:
			$"left eye node/left eye".lifetime = 0.1
			$"right eye node/right eye".lifetime = 0.1
	elif $"left eye node/left eye".lifetime == 0.1:
		$"left eye node/left eye".lifetime = 0.2
		$"right eye node/right eye".lifetime = 0.2
	input.x = int(Input.is_action_pressed("blue_right")) - int(Input.is_action_pressed("blue_left"))
	input.y = int(Input.is_action_pressed("blue_down")) - int(Input.is_action_pressed("blue_up"))
	return input.normalized()

func player_movement(delta):
	input = get_input()

	if input == Vector2.ZERO:
		if velocity.length() > ((friction + friction_boost) * delta):
			velocity -= velocity.normalized() * ((friction + friction_boost) * delta)
		else:
			velocity = Vector2.ZERO
	else:
		velocity += (input * (accel + accel_boost) * delta)
		velocity = velocity.limit_length(speed + speed_boost)
		
	move_and_slide()

func shoot():
	if powered_next_bullet == false:
		$bulletsfx.play()
		var bullet_scene = preload("res://player/attacks/bullet/bullet.tscn")
		var shot = bullet_scene.instantiate() 
		add_sibling(shot)
		shot.shoot(global_position, get_global_mouse_position())
		var effect := bullet_explosion.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		effect.shoot(global_position, get_global_mouse_position())
		$GunTimer.start()
	else:
		$fresh_bulletsfx.play()
		$fresh_bullet2sfx.play()
		$powered_bullet2.visible = false
		powered_next_bullet = false
		var bullet_scene = preload("res://player/attacks/bullet/big_bullet.tscn")
		var shot = bullet_scene.instantiate()
		get_parent().add_child(shot)
		shot.shoot(global_position, get_global_mouse_position())
		var effect := alt_bullet_explosion.instantiate()
		effect.position = position
		effect.modulate = Color(0, 1, 1, 1)
		get_parent().add_child(effect)
		effect.shoot(global_position, get_global_mouse_position())
		get_node("../camera").apply_shake(5, 0.25)
		$GunTimer.start()

func shootm2():
	if gunm2_cooldown > 100 and not get_tree().has_group("beam") and get_node("/root/player_global").got_bulletm2:
		var bullet_scene = preload("res://player/attacks/bullet/bulletm2.tscn")
		var shot = bullet_scene.instantiate()
		get_parent().add_child(shot)
		shot.shoot(global_position, get_global_mouse_position())
		gunm2_cooldown = 0

func power_next_bullet():
	powered_next_bullet = true
	$powered_bulletsfx.play()
	$powered_bullet1.emitting = true
	$powered_bullet2.visible = true
	$powered_bullet2/particle.modulate = Color(0, 1, 1, 0)
	create_tween().tween_property($powered_bullet2/particle, "modulate", Color(1, 1, 1, 1), 1)

func alt_shoot():
	if not get_tree().has_group("alt_bullet"):
		$alt_bulletsfx.play()
		var bullet_scene = preload("res://player/attacks/alt_bullet/alt_bullet.tscn")
		var shot = bullet_scene.instantiate() 
		get_parent().add_child(shot)
		shot.shoot(global_position, get_global_mouse_position())
		var effect := alt_bullet_explosion.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		effect.shoot(global_position, get_global_mouse_position())
		$Alt_GunTimer.start()

func alt_shootm2():
	if alt_gunm2_cooldown > 100 and not get_tree().has_group("bulletm2"): #aaaaaaaaaaaaaaaa
		$lasersfx.play()
		var bullet_scene = preload("res://player/attacks/alt_bullet/beam.tscn")
		var shot = bullet_scene.instantiate()
		get_parent().add_child(shot)
		shot.shoot(global_position, get_global_mouse_position())
		alt_gunm2_cooldown = 0 #aaaaaaaaaaaaaaaaaaaaaaaaaa

func melee():
	var bullet_scene = preload("res://player/attacks/melee/melee_new.tscn")
	var shot = bullet_scene.instantiate()
	var radius = 200
	var offset = get_global_mouse_position() - global_position
	if offset.length() > radius:
		offset = offset.normalized() * radius
	var spawn_position = global_position + offset
	shot.offset = offset
	shot.global_position = spawn_position
	if melee_order == 1:
		shot.scale = Vector2(3, 3)
		shot.square_collision_pos = Vector2(17, 0)
		melee_order += 1
	else:
		shot.scale = Vector2(-3, -3)
		shot.square_collision_pos = Vector2(-17, 0)
		melee_order -= 1
	get_parent().add_child(shot)
	$MeleeTimer.start()

func meleem2():
	if meleem2_cooldown > 100:
		var effect := preload("res://player/attacks/melee/meleem2.tscn").instantiate()
		effect.position = position
		get_parent().add_child(effect)
		meleem2_cooldown = 0

func dash():
	var effect := dash_particles.instantiate()
	effect.position = position
	get_parent().add_child(effect)
	amount_of_i_frames += 1
	stamina -= 50
	friction *= 3
	accel *= 5
	speed *= 2
	$DashLength.start()
	$dashsfx.play()

func _on_dash_length_timeout() -> void:
	friction /= 3
	accel /= 5
	speed /= 2
	amount_of_i_frames -= 1

func parry():
	$parry_detection/CollisionShape2D.disabled = false
	parry_cooldown = 0
	$parrysfx.play()
	var effect := parry_particles.instantiate()
	effect.position = position
	get_parent().add_child(effect)
	await get_tree().create_timer(0.15, false).timeout
	$parry_detection/CollisionShape2D.disabled = true

func _on_parry_detection_area_entered(area):
	if area.is_in_group("parryable"):
		$parry_detection/CollisionShape2D.set_deferred("disabled", true)
		$parriedsfx.play()
		var effect := parried_particles.instantiate()
		effect.position = position
		get_parent().call_deferred("add_child", effect)
		if parry_cooldown < 15:
			parry_cooldown += 15
		framefreeze(0.1, 0.3)
		if area.is_in_group("enemy_attack"):
			i_frames(1)
			if speed_boost < 300:
				speed_boost += 300
				accel_boost += 3000
				friction_boost += 1710

func framefreeze(timescale, duration):
	if is_dead == false:
		Engine.time_scale = timescale
		await get_tree().create_timer(duration, true, false, true).timeout
		Engine.time_scale = 1.0

func player_hurt_particles():
	if is_dead == false:
		parry_cooldown = clamp(parry_cooldown - 15, 0, 30)
		var effect := player_hurt.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		get_node("../camera").apply_shake(5, 0.1)
		speed_boost = 0
		accel_boost = 0
		friction_boost = 0
		got_hit = true
		await get_tree().create_timer(0.99, false).timeout
		got_hit = false

func i_frames(duration):
	if is_dead == false:
		amount_of_i_frames += 1
		await get_tree().create_timer(duration, false).timeout
		amount_of_i_frames -= 1

func _on_player_hurtbox_area_entered(area):
	if area.is_in_group("enemy_attack"):
		take_damage += 1
	if area.is_in_group("level end") and is_dead == false:
		speed = 0
		speed_boost = 0
		$"left eye node/left eye".lifetime = 0.2
		$"right eye node/right eye".lifetime = 0.2
		var tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_ELASTIC)
		tween.tween_property(self, "position", Vector2(area.position + Vector2(0, -300)), 1)
		is_dead = true
		get_tree().create_tween().tween_property(get_node("../ui/health"), "modulate", Color(1, 1, 1, 0), 1)
		get_tree().create_tween().tween_property(get_node("../ui/staminabar"), "modulate", Color(1, 1, 1, 0), 1)
		await get_tree().create_timer(2, false).timeout
		$level_end_chargesfx.play()
		get_node("../camera").apply_shake(10, 1.15)
		await get_tree().create_timer(1, false).timeout
		$dashsfx.play()
		in_intro = true
		await get_tree().create_timer(0.15, false).timeout
		in_intro = false
		$body.emitting = false
		$"left eye node/left eye".emitting = false
		$"right eye node/right eye".emitting = false
		$"combat eye".visible = false
		$"combat eye2".visible = false
		var effect := player_death.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		await get_tree().create_timer(1, false).timeout
		get_node("../ui/screen_transition").visible = true
		get_tree().create_tween().tween_property(get_node("../ui/screen_transition"), "color", Color(0, 0, 0, 1.5), 1)
		await get_tree().create_timer(2).timeout
		add_to_group("next level")
	if area.is_in_group("level start"):
		$landingsfx.play()
		in_intro = false
		speed = 700
		var effect := player_land.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		area.remove_from_group("level start")
		get_node("../camera").apply_shake(10, 0.5)

func _on_player_hurtbox_area_exited(area):
	if area.is_in_group("enemy_attack"):
		take_damage -= 1

func heal_particles():
	var effect := dash_particles.instantiate()
	effect.position = position
	effect.color = Color(1, 1, 1, 1)
	get_parent().add_child(effect)
	$healsfx.play()

func add_heal_cooldown(amount):
	if got_hit == false:
		heal_cooldown = clamp(heal_cooldown + amount, 0, 100)
