extends CharacterBody2D

var dash_particles := preload("res://player/player_dash_particles.tscn")
var parry_particles := preload("res://player/attacks/parry_particles.tscn")
var parried_particles := preload("res://player/attacks/parried_particles.tscn")
var player_hurt := preload("res://player/player_hurt.tscn")
var player_death := preload("res://player/player_death.tscn")
var bullet_explosion := preload("res://player/attacks/bullet_explosion.tscn")
var melee_alt := preload("res://player/attacks/melee_alt.tscn")

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
var enemies_in_area = 0
var is_dead = false
var stamina_tween = true
var melee_order = 1
var first_weapon = true
var second_weapon = false
var is_dashing = false
var attackable = true
var amount_of_i_frames = 0
var heal_cooldown = 0
var parry_cooldown = 30
var parried = false

func _physics_process(delta):
	player_movement(delta)

func _process(delta):
	if stamina <= 100:
		stamina += 25 * delta
	if alt_gun_cooldown <= 100:
		alt_gun_cooldown += 50 * delta
	if alt_melee_cooldown <= 100:
		alt_melee_cooldown += 25 * delta
	if parry_cooldown <= 30:
		parry_cooldown += 10 * delta

	if Input.is_action_pressed("dash") and stamina > 50 and is_dashing == false and is_dead == false:
		dash()
		stamina_tween = false
		
	if Input.is_action_pressed("parry") and parry_cooldown > 30 and is_dead == false:
		parry()
	if health < 1 and is_dead == false:
		var effect := player_death.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		speed = 0
		speed_boost = 0
		$body.emitting = false
		$"left eye node/left eye".emitting = false
		$"right eye node/right eye".emitting = false
		$"combat eye".visible = false
		$"combat eye2".visible = false
		is_dead = true
	if Input.is_action_pressed("left_mouse_button") and $GunTimer.is_stopped() and first_weapon and is_dead == false:
		shoot()
	if Input.is_action_pressed("right_mouse_button") and first_weapon and is_dead == false:
		alt_shoot()
	if Input.is_action_pressed("left_mouse_button") and $MeleeTimer.is_stopped() and second_weapon and is_dead == false:
		melee()
	if Input.is_action_pressed("right_mouse_button") and second_weapon and is_dead == false:
		alt_melee()
	if Input.is_action_pressed("first_weapon"):
		first_weapon = true
		second_weapon = false
	if Input.is_action_pressed("second_weapon"):
		first_weapon = false
		second_weapon = true

	if amount_of_i_frames == 0:
		attackable = true
	else:
		attackable = false
	if heal_cooldown >= 100 and health < 3 and is_dead == false:
		health += 1
		heal_cooldown = 0

func get_input():
	if input.length() > 0.0:
		$"left eye node/left eye".lifetime = 0.1
		$"right eye node/right eye".lifetime = 0.1
	else:
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
	if alt_gun_cooldown > 100:
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

func _on_combat_eye_detection_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy") or area.is_in_group("enemy_attack") or area.is_in_group("spawn"):
		enemies_in_area += 1
		$"combat eye".emitting = true
		$"combat eye2".emitting = true

func _on_combat_eye_detection_area_exited(area: Area2D) -> void:
	if area.is_in_group("enemy") or area.is_in_group("enemy_attack") or area.is_in_group("spawn"):
		enemies_in_area -= 1
		if enemies_in_area == 0:
			$"combat eye".emitting = false
			$"combat eye2".emitting = false

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
	Engine.time_scale = timescale
	await(get_tree().create_timer(duration * timescale).timeout)
	Engine.time_scale = 1.0

func player_hurt_particles():
	parry_cooldown = 0
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
