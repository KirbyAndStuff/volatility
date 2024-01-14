extends CharacterBody2D

var purple_hurt := preload("res://enemies/purple/purple_hurt3.tscn")

func _ready():
	$playerdeath/CollisionShape2D.disabled = true
	await get_tree().create_timer(0.3).timeout
	$playerdeath/CollisionShape2D.disabled = false

var speed = 500
var player_chase = false
var player = null
var attack_player = false
var purple_health = 1

func _physics_process(delta):
	if player_chase:
		var direction = (player.position-position).normalized()
		velocity=direction*speed
		move_and_slide()

func _process(delta):
	if attack_player and (get_node("../player").i_frames) == false and (get_node("../player").dashi_frames) == false:
		(get_node("../player").health) -= 1
		(get_node("../player").i_frames) = true
		(get_node("../player").player_hurt_particles())
		(get_node("../player").framefreeze(0.4, 0.3))
	if purple_health < 1:
		queue_free()

func _on_playerdeath_area_entered(area):
	if area.name == "bullet_hurtbox":
		var effect := purple_hurt.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		purple_health -= 1
	if area.name == "parried_hurtbox":
		purple_health -= 2

func _on_player_detection_body_entered(body):
	if body.name == "player":
		player = body
		player_chase = true

func _on_player_detection_body_exited(body):
	if body.name == "player":
		player = null
		player_chase = false

func _on_hurts_player_body_entered(body):
	if body.name == "player":
		attack_player = true

func _on_hurts_player_body_exited(body):
	if body.name == "player":
		attack_player = false
