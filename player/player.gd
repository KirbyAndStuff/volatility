extends CharacterBody2D

var dash_particles := preload("res://player/player_dash_particles.tscn")
var parry_particles := preload("res://player/attacks/parry_particles.tscn")
var parried_particles := preload("res://player/attacks/parried_particles.tscn")
var player_hurt := preload("res://player/player_hurt.tscn")
var player_death := preload("res://player/player_death.tscn")
var bullet_explosion := preload("res://player/attacks/bullet_explosion.tscn")
var melee_alt := preload("res://player/attacks/melee_alt.tscn")
var player_land := preload("res://player/player_land.tscn")

var health = 3
var speed = 700
var speed_boost = 0
var accel = 7000
var accel_boost = 0
var friction = 4000
var friction_boost = 0
var stamina = 100
var alt_gun_cooldown = 100
var alt_melee_cooldown = 100
var input = Vector2.ZERO
var is_dead = false
var stamina_tween = true
var melee_order = 1
var active_weapon = 1
var can_scroll_up = true
var can_scroll_down = true
var is_dashing = false
var attackable = true
var amount_of_i_frames = 0
var heal_cooldown = 0
var parry_cooldown = 30
var parried = false
var in_intro = false

func _physics_process(delta):
	player_movement(delta)
	if stamina <= 100:
		stamina += 25 * delta
	if alt_gun_cooldown <= 100:
		alt_gun_cooldown += 50 * delta
	if alt_melee_cooldown <= 100:
		alt_melee_cooldown += 25 * delta
	if parry_cooldown <= 30:
		parry_cooldown += 10 * delta
	if in_intro:
		speed = 0
		$"left eye node/left eye".lifetime = 0.1
		$"right eye node/right eye".lifetime = 0.1
		position.y += 2000 * delta

func _process(_delta):
	if Input.is_action_pressed("dash") and stamina > 50 and is_dashing == false and is_dead == false and in_intro == false:
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
	if Input.is_action_pressed("left_mouse_button") and $GunTimer.is_stopped() and active_weapon == 1 and is_dead == false and in_intro == false:
		shoot()
	if Input.is_action_pressed("right_mouse_button") and active_weapon == 1 and is_dead == false and in_intro == false:
		alt_shoot()
	if Input.is_action_pressed("left_mouse_button") and $MeleeTimer.is_stopped() and active_weapon == 2 and is_dead == false and in_intro == false:
		melee()
	if Input.is_action_pressed("right_mouse_button") and active_weapon == 2 and is_dead == false and in_intro == false:
		alt_melee()
	if Input.is_action_pressed("first_weapon"):
		active_weapon = 1
	if Input.is_action_pressed("second_weapon"):
		active_weapon = 2
	if Input.is_action_just_pressed("scroll_up") and can_scroll_up:
		can_scroll_up = false
		active_weapon += 1
		if active_weapon > get_node("/root/player_global").weapon_list.size() + 1:
			active_weapon = 1
		await get_tree().create_timer(0.2, false).timeout
		can_scroll_up = true
	if Input.is_action_just_pressed("scroll_down") and can_scroll_down:
		can_scroll_down = false
		active_weapon -= 1
		if active_weapon < 1:
			active_weapon = get_node("/root/player_global").weapon_list.size() + 1
		await get_tree().create_timer(0.2, false).timeout
		can_scroll_down = true
	if amount_of_i_frames == 0:
		attackable = true
	else:
		attackable = false
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
	$bulletsfx.play()
	var bullet_scene = preload("res://player/attacks/bullet.tscn")
	var shot = bullet_scene.instantiate() 
	get_parent().add_child(shot)
	shot.shoot(global_position, get_global_mouse_position())
	var effect := bullet_explosion.instantiate()
	effect.position = position
	get_parent().add_child(effect)
	effect.shoot(global_position, get_global_mouse_position())
	$GunTimer.start()

func alt_shoot():
	if alt_gun_cooldown > 100 and get_node("/root/player_global").got_beam:
		$lasersfx.play()
		var bullet_scene = preload("res://player/attacks/beam.tscn")
		var shot = bullet_scene.instantiate()
		get_parent().add_child(shot)
		shot.shoot(global_position, get_global_mouse_position())
		alt_gun_cooldown = 0

func melee():
	if melee_order == 1:
		var bullet_scene = preload("res://player/attacks/melee_up.tscn")
		var shot = bullet_scene.instantiate() 
		get_parent().add_child(shot)
		shot.shoot(global_position, get_global_mouse_position())
		$MeleeTimer.start()
		melee_order += 1
	else:
		var bullet_scene = preload("res://player/attacks/melee_down.tscn")
		var shot = bullet_scene.instantiate() 
		get_parent().add_child(shot)
		shot.shoot(global_position, get_global_mouse_position())
		$MeleeTimer.start()
		melee_order -= 1

func alt_melee():
	if alt_melee_cooldown > 100:
		var effect := melee_alt.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		alt_melee_cooldown = 0

func dash():
	var effect := dash_particles.instantiate()
	effect.position = position
	get_parent().add_child(effect)
	amount_of_i_frames += 1
	is_dashing = true
	stamina -= 50
	friction *= 3
	accel *= 5
	speed *= 2
	$DashLength.start()
	$dashsfx.play()

func _on_dash_length_timeout() -> void:
	is_dashing = false
	friction /= 3
	accel /= 5
	speed /= 2
	amount_of_i_frames -= 1

func parry():
	$parrysfx.play()
	var effect := parry_particles.instantiate()
	effect.position = position
	get_parent().add_child(effect)
	$parry_detection/CollisionShape2D.disabled = false
	parry_cooldown = 0
	await get_tree().create_timer(0.15, false).timeout
	$parry_detection/CollisionShape2D.disabled = true

func _on_parry_detection_area_entered(area):
	if area.is_in_group("enemy_attack"):
		var tween = create_tween()
		tween.tween_property((get_node("../ui/health").parry), "modulate", Color(1, 1, 1), 1.5)
		$parriedsfx.play()
		i_frames(1.5)
		var effect := parried_particles.instantiate()
		effect.position = position
		get_parent().call_deferred("add_child", effect)
		if parried == false:
			parry_cooldown += 15
			parried = true
		if speed_boost < 300:
			speed_boost += 300
			accel_boost += 3000
			friction_boost += 1710
		framefreeze(0.1, 0.3)
		await get_tree().create_timer(1.5, false).timeout
		parried = false

func framefreeze(timescale, duration):
	if is_dead == false:
		Engine.time_scale = timescale
		await(get_tree().create_timer(duration * timescale).timeout)
		Engine.time_scale = 1.0

func player_hurt_particles():
	if is_dead == false:
		parry_cooldown = clamp(parry_cooldown - 15, 0, 30)
		var effect := player_hurt.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		speed_boost = 0
		accel_boost = 0
		friction_boost = 0

func i_frames(duration):
	amount_of_i_frames += 1
	await get_tree().create_timer(duration, false).timeout
	amount_of_i_frames -= 1

func _on_player_hurtbox_area_entered(area):
	if area.is_in_group("level end") and is_dead == false:
		speed = 0
		speed_boost = 0
		var tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_ELASTIC)
		tween.tween_property(self, "position", Vector2(area.position + Vector2(0, -300)), 1)
		is_dead = true
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
		await get_tree().create_timer(3, false).timeout
		add_to_group("next level")
	if area.is_in_group("level start"):
		$"left eye node/left eye".lifetime = 0.2
		$"right eye node/right eye".lifetime = 0.2
		$landingsfx.play()
		in_intro = false
		speed = 700
		var effect := player_land.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		area.remove_from_group("level start")
		get_node("../camera").apply_shake(10, 0.5)

func heal_particles():
	var effect := dash_particles.instantiate()
	effect.position = position
	effect.color = Color(1, 1, 1, 1)
	get_parent().add_child(effect)
	$healsfx.play()
