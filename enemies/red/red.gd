extends CharacterBody2D

var particlesL: CPUParticles2D
var particlesR: CPUParticles2D
var red_death := preload("res://enemies/red/red_death.tscn")
var red_dash_particles := preload("res://enemies/red/red_dash_particles.tscn")
var red_hurt := preload("res://enemies/red/red_hurt.tscn")

func _ready():
	particlesL = $"left eye"
	particlesR = $"right eye"
	var effect := red_hurt.instantiate()
	effect.position = position
	get_parent().add_child(effect)

var speed = 300
var player_chase = false
var player = null
var attack_player = false
var dash_at_player = false
var red_stamina = 20
var red_health = 2
var is_stunned = false

@onready var red_dashlength = $Red_DashLength

func _physics_process(_delta):
	if player_chase:
		var direction = (player.position-position).normalized()
		velocity=direction*speed
		move_and_slide()

func _process(delta):
	if attack_player and (get_node("../player").i_frames) == false and (get_node("../player").dashi_frames) == false and is_stunned == false:
		(get_node("../player").health) -= 1
		(get_node("../player").i_frames) = true
		(get_node("../player").player_hurt_particles())
		(get_node("../player").framefreeze(0.4, 0.3))
	if red_stamina <= 20:
		red_stamina += 10 * delta
	if dash_at_player and red_stamina > 19:
		red_stamina -= 20
		var effect := red_dash_particles.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		await get_tree().create_timer(0.5).timeout
		if is_stunned == false:
			$red_dashsfx.play()
			speed = 1500
			red_dashlength.start()
	if red_health < 1:
		var effect := red_death.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		queue_free()

func _on_playerdeath_area_entered(area):
	if area.name == "bullet_hurtbox":
		var effect := red_hurt.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		red_health -= 1
	if area.name == "parried_hurtbox":
		is_stunned = true
		speed = 0
		dash_at_player = false
		$"left eye".emitting = false
		$"right eye".emitting = false
		$"stunned_eye".emitting = true
		$"stunned_eye2".emitting = true
		$"stunned_eye3".emitting = true
		$"stunned_eye4".emitting = true
		$Stunned.start()
	if area.is_in_group("beam"):
		var effect := red_hurt.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		red_health -= 2

func _on_red_dash_length_timeout() -> void:
	speed = 300

func _on_timer_timeout():
	$"left eye".emitting = true
	$"right eye".emitting = true
	$"stunned_eye".emitting = false
	$"stunned_eye2".emitting = false
	$"stunned_eye3".emitting = false
	$"stunned_eye4".emitting = false
	is_stunned = false
	speed = 300

func _on_player_detection_area_entered(area):
	if area.is_in_group("player"):
		player = area.get_parent()
		player_chase = true
		particlesL.lifetime = 0.1
		particlesR.lifetime = 0.1

func _on_player_detection_area_exited(area):
	if area.is_in_group("player"):
		player = null
		player_chase = false
		particlesL.lifetime = 0.2
		particlesR.lifetime = 0.2

func _on_hurts_player_area_entered(area):
	if area.is_in_group("player"):
		attack_player = true

func _on_hurts_player_area_exited(area):
	if area.is_in_group("player"):
		attack_player = false

func _on_player_dash_distance_area_entered(area):
	if area.is_in_group("player") and is_stunned == false:
		dash_at_player = true

func _on_player_dash_distance_area_exited(area):
	if area.is_in_group("player"):
		dash_at_player = false
