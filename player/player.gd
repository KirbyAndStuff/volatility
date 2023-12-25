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

@onready var guntimer := $GunTimer
@onready var dashlength := $DashLength
@onready var dash_particlestimer := $DashParticles
@onready var i_frameslength := $I_FramesLength
@onready var dashi_frameslength := $DashI_FramesLength
@onready var parrytimer := $ParryTimer

func _ready():
	particlesB = $"body"
	particlesL = $"left eye node/left eye"
	particlesR = $"right eye node/right eye"
	combat_eye = $"combat eye"

var health = 3
var speed = 500
var accel = 7000
var friction = 2000
var stamina = 100
var input = Vector2.ZERO
var i_frames = false
var dashi_frames = false
var enemies_in_area = 0
var is_dead = false

func _physics_process(delta):
	player_movement(delta)

func _process(delta):
	if stamina <= 100:
		stamina += 25 * delta
		
	if Input.is_action_pressed("left_mouse_button") and guntimer.is_stopped():
		shoot()
		
	if Input.is_action_pressed("dash") and stamina > 50 and dash_particlestimer.is_stopped():
		var effect := dash_particles.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		dash_particlestimer.start()
		
	if Input.is_action_pressed("dash") and stamina > 50:
		dash()
		dashi_framesss()
		
	if i_frames == true and i_frameslength.is_stopped():
		i_framesss()
	if Input.is_action_pressed("parry"):
		parry()
	if health < 1 and is_dead == false:
		var effect := player_death.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		speed = 0
		particlesB.emitting = false
		particlesL.emitting = false
		particlesR.emitting = false
		combat_eye.emitting = false
		is_dead = true

func get_input():
	if input.length() > 0.0:
		particlesL.lifetime = 0.1
	else:
		particlesL.lifetime = 0.2
	if input.length() > 0.0:
		particlesR.lifetime = 0.1
	else:
		particlesR.lifetime = 0.2
	input.x = int(Input.is_action_pressed("blue_right")) - int(Input.is_action_pressed("blue_left"))
	input.y = int(Input.is_action_pressed("blue_down")) - int(Input.is_action_pressed("blue_up"))
	return input.normalized()

func player_movement(delta):
	input = get_input()
	
	if input == Vector2.ZERO:
		if velocity.length() > (friction * delta):
			velocity -= velocity.normalized() * (friction * delta)
		else:
			velocity = Vector2.ZERO
	else:
		velocity += (input * accel * delta)
		velocity = velocity.limit_length(speed)
		
	move_and_slide()

func shoot():
	var bullet_scene = preload("res://player/attacks/bullet_4.tscn")
	var shot = bullet_scene.instantiate() 
	get_parent().add_child(shot)
	shot.shoot(global_position, get_global_mouse_position())
	guntimer.start()

func _on_cooldown_timer_timeout() -> void:
	guntimer.stop()

func dash():
	if speed == 500:
		stamina -= 50
		friction *= 3
		accel *= 5
		speed *= 2
		dashlength.start()
		$dashsfx.play()

func i_framesss():
	i_frames = true
	i_frameslength.start()
	
func dashi_framesss():
	dashi_frames = true
	dashi_frameslength.start()

func _on_dash_length_timeout() -> void:
	friction = 2000
	accel = 7000
	speed = 500

func _on_dash_particles_timeout() -> void:
	dash_particlestimer.stop()

func _on_i_frames_length_timeout() -> void:
	i_frames = false
	i_frameslength.stop()

func _on_dash_i_frames_length_timeout() -> void:
	dashi_frames = false
	dashi_frameslength.stop()

func _on_combat_eye_detection_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		enemies_in_area += 1
		combat_eye.emitting = true

func _on_combat_eye_detection_area_exited(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		enemies_in_area -= 1
		if enemies_in_area == 0:
			combat_eye.emitting = false

func parry():
	if parrytimer.is_stopped():
		var effect := parry_particles.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		$parry_detection/CollisionShape2D.disabled = false
		parrytimer.start()
		await get_tree().create_timer(0.15).timeout
		$parry_detection/CollisionShape2D.disabled = true

func _on_parry_timer_timeout() -> void:
	parrytimer.stop()

func _on_parry_detection_area_entered(area: Area2D) -> void:
	if area.is_in_group("attack"):
		i_framesss()
		var effect := parried_particles.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		framefreeze(0.4, 0.3)

func framefreeze(timescale, duration):
	Engine.time_scale = timescale
	await(get_tree().create_timer(duration * timescale).timeout)
	Engine.time_scale = 1.0

func player_hurt_particles():
	var effect := player_hurt.instantiate()
	effect.position = position
	get_parent().add_child(effect)
