extends CharacterBody2D

var particlesL: CPUParticles2D
var particlesR: CPUParticles2D
var red_death := preload("res://enemies/red/red_death.tscn")
var red_dash_particles := preload("res://enemies/red/red_dash_particles.tscn")
var red_hurt := preload("res://enemies/red/red_hurt.tscn")

func _ready():
	var effect := red_hurt.instantiate()
	effect.position = position
	get_parent().call_deferred("add_child", effect)

var speed = 500
var player_chase = false
var player = null
var attack_player = false
var dash_at_player = false
var red_stamina = 20
var red_health = 2
var is_stunned = false

@onready var red_dashlength = $Red_DashLength
@onready var eyes = [$"left eye", $"right eye"]
@onready var stunned_eyes = [$stunned_eye, $stunned_eye2, $stunned_eye3, $stunned_eye4]

func _physics_process(_delta):
	if player_chase:
		var direction = (player.position-position).normalized()
		velocity=direction*speed
		move_and_slide()

func _process(delta):
	if attack_player and (get_node("../player").attackable) == true and is_stunned == false:
		(get_node("../player").health) -= 1
		(get_node("../player").i_frames(1))
		(get_node("../player").player_hurt_particles())
		(get_node("../player").framefreeze(0.4, 0.3))
	if red_stamina <= 20:
		red_stamina += 10 * delta
	if dash_at_player and red_stamina > 19:
		$is_about_to_dashsfx.play()
		red_stamina -= 20
		var effect := red_dash_particles.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		await get_tree().create_timer(0.5, false).timeout
		if is_stunned == false:
			$red_dashsfx.play()
			speed *= 4
			red_dashlength.start()
	if red_health < 1:
		var effect := red_death.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		queue_free()

func _on_playerdeath_area_entered(area):
	if area.is_in_group("deal 1 damage"):
		var effect := red_hurt.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		red_health -= 1
	if area.is_in_group("parry"):
		is_stunned = true
		speed = 0
		dash_at_player = false
		for vol in eyes:
			vol.emitting = false
		for vol in stunned_eyes:
			vol.emitting = true
		$Stunned.start()
	if area.is_in_group("deal 2 damage"):
		var effect := red_hurt.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		red_health -= 2
	if area.is_in_group("deal 3 damage"):
		var effect := red_hurt.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		red_health -= 3

func _on_red_dash_length_timeout() -> void:
	speed /= 4

func _on_timer_timeout():
	for vol in eyes:
		vol.emitting = true
	for vol in stunned_eyes:
		vol.emitting = false
	is_stunned = false
	speed = 500

func _on_player_detection_area_entered(area):
	if area.is_in_group("player"):
		player = area.get_parent()
		player_chase = true
		$"left eye".lifetime = 0.1
		$"right eye".lifetime = 0.1

func _on_player_detection_area_exited(area):
	if area.is_in_group("player"):
		player = null
		player_chase = false
		$"left eye".lifetime = 0.2
		$"right eye".lifetime = 0.2

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
