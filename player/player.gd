extends CharacterBody2D

var particlesB: CPUParticles2D
var particlesL: CPUParticles2D
var particlesR: CPUParticles2D
var combat_eye: CPUParticles2D
var dash_particles := preload("res://player/player_dash_particles.tscn")
var parry_particles := preload("res://player/attacks/parry_particles.tscn")
var parried_particles := preload("res://player/attacks/parried_particles.tscn")
var player_hurt := preload("res://player/player_hurt.tscn")
var player_death := preload("res://player/player_death.tscn")
var bullet_explosion := preload("res://player/attacks/bullet_4_explosion.tscn")
var melee_alt := preload("res://player/attacks/melee_alt.tscn")

@onready var guntimer := $GunTimer
@onready var dashlength := $DashLength
@onready var dash_particlestimer := $DashParticles
@onready var parrytimer := $ParryTimer

func _ready():
	particlesB = $"body"
	particlesL = $"left eye node/left eye"
	particlesR = $"right eye node/right eye"
	combat_eye = $"combat eye"

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
var parry_tween = false
var melee_order = 1
var first_weapon = true
var second_weapon = false
var is_dashing = false
var attackable = true
var amount_of_i_frames = 0
var alt_melee_active = false
var heal_cooldown = 0

func _physics_process(delta):
	player_movement(delta)

func _process(delta):
	if stamina <= 100:
		stamina += 25 * delta
	if alt_gun_cooldown <= 100:
		alt_gun_cooldown += 50 * delta
	if alt_melee_cooldown <= 100:
		alt_melee_cooldown += 20 * delta

	if Input.is_action_pressed("left_mouse_button") and guntimer.is_stopped() and first_weapon and is_dead == false and alt_melee_active == false:
		shoot()
		
	if Input.is_action_pressed("dash") and stamina > 50 and dash_particlestimer.is_stopped() and is_dead == false:
		var effect := dash_particles.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		dash_particlestimer.start()
		
	if Input.is_action_pressed("dash") and stamina > 50 and is_dashing == false and is_dead == false:
		dash()
		stamina_tween = false
		
	if Input.is_action_pressed("parry") and is_dead == false and alt_melee_active == false:
		parry()
	if health < 1 and is_dead == false:
		var effect := player_death.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		speed = 0
		speed_boost = 0
		particlesB.emitting = false
		particlesL.emitting = false
		particlesR.emitting = false
		combat_eye.visible = false
		$"combat eye2".visible = false
		is_dead = true
	if Input.is_action_pressed("right_mouse_button") and first_weapon and is_dead == false and alt_melee_active == false:
		alt_shoot()
	if Input.is_action_pressed("left_mouse_button") and $MeleeTimer.is_stopped() and second_weapon and is_dead == false and alt_melee_active == false:
		melee()
	if Input.is_action_pressed("right_mouse_button") and $MeleeTimer.is_stopped() and second_weapon and is_dead == false:
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
	if Input.is_action_pressed("heal") and heal_cooldown >= 100 and health < 3 and is_dead == false:
		health += 1
		heal_cooldown = 0

func get_input():
	if input.length() > 0.0:
		particlesL.lifetime = 0.1
		particlesR.lifetime = 0.1
	else:
		particlesL.lifetime = 0.2
		particlesR.lifetime = 0.2
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
	var bullet_scene = preload("res://player/attacks/bullet_4.tscn")
	var shot = bullet_scene.instantiate() 
	get_parent().add_child(shot)
	shot.shoot(global_position, get_global_mouse_position())
	var effect := bullet_explosion.instantiate()
	effect.position = position
	get_parent().add_child(effect)
	effect.shoot(global_position, get_global_mouse_position())
	guntimer.start()

func alt_shoot():
	if alt_gun_cooldown > 100:
		$lasersfx.play()
		var bullet_scene = preload("res://player/attacks/beam2.tscn")
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
		alt_melee_active = true
		amount_of_i_frames += 1
		$body.modulate = Color(1, 1, 1, 0.25)
		$"left eye node/left eye".modulate = Color(1, 1, 1, 0.25)
		$"right eye node/right eye".modulate = Color(1, 1, 1, 0.25)
		var effect := melee_alt.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		alt_melee_cooldown = 0
		await get_tree().create_timer(1.5, false).timeout
		$body.modulate = Color(1, 1, 1, 1)
		$"left eye node/left eye".modulate = Color(1, 1, 1, 1)
		$"right eye node/right eye".modulate = Color(1, 1, 1, 1)
		amount_of_i_frames -= 1
		alt_melee_active = false

func dash():
	amount_of_i_frames += 1
	is_dashing = true
	stamina -= 50
	friction *= 3
	accel *= 5
	speed *= 2
	dashlength.start()
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
		combat_eye.emitting = true
		$"combat eye2".emitting = true

func _on_combat_eye_detection_area_exited(area: Area2D) -> void:
	if area.is_in_group("enemy") or area.is_in_group("enemy_attack") or area.is_in_group("spawn"):
		enemies_in_area -= 1
		if enemies_in_area == 0:
			combat_eye.emitting = false
			$"combat eye2".emitting = false

func parry():
	if parrytimer.is_stopped():
		$parrysfx.play()
		var effect := parry_particles.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		$parry_detection/CollisionShape2D.disabled = false
		parrytimer.start()
		await get_tree().create_timer(0.15, false).timeout
		$parry_detection/CollisionShape2D.disabled = true
		if parry_tween == false:
			var tween = create_tween()
			tween.tween_property((get_node("../ui/health").parry), "modulate", Color(1, 1, 1), 3)

func _on_parry_detection_area_entered(area):
	if area.is_in_group("enemy_attack"):
		parry_tween = true
		var tween = create_tween()
		tween.tween_property((get_node("../ui/health").parry), "modulate", Color(1, 1, 1), 1.5)
		$parriedsfx.play()
		amount_of_i_frames += 1
		var effect := parried_particles.instantiate()
		effect.position = position
		get_parent().call_deferred("add_child", effect)
		if speed_boost < 500:
			speed_boost += 100
			accel_boost += 1000
			friction_boost += 570
		$SpeedBoostTimer.start()
		framefreeze(0.1, 0.3)
		await get_tree().create_timer(1, false).timeout
		amount_of_i_frames -= 1
		await get_tree().create_timer(0.5, false).timeout
		$ParryTimer.stop()
		parry_tween = false

func framefreeze(timescale, duration):
	Engine.time_scale = timescale
	await(get_tree().create_timer(duration * timescale).timeout)
	Engine.time_scale = 1.0

func player_hurt_particles():
	var effect := player_hurt.instantiate()
	effect.position = position
	get_parent().add_child(effect)

func _on_speed_boost_timer_timeout():
	speed_boost = 0
	accel_boost = 0
	friction_boost = 0

func i_frames():
	amount_of_i_frames += 1
	await get_tree().create_timer(1, false).timeout
	amount_of_i_frames -= 1
