extends CharacterBody2D

var purple_hurt := preload("res://enemies/purple/purple_hurt3.tscn")

func _ready():
	$playerdeath/CollisionShape2D.disabled = true
	$hurts_player/CollisionShape2D.disabled = true
	await get_tree().create_timer(0.3).timeout
	$playerdeath/CollisionShape2D.disabled = false
	$hurts_player/CollisionShape2D.disabled = false

var speed = 700
var player_chase = false
var player = null
var attack_player = false
var purple_health = 1
var is_stunned = false

func _physics_process(_delta):
	if player_chase:
		var direction = (player.position-position).normalized()
		velocity=direction*speed
		move_and_slide()

func _process(_delta):
	if attack_player and (get_node("../player").i_frames) == false and (get_node("../player").dashi_frames) == false and is_stunned == false:
		(get_node("../player").health) -= 1
		(get_node("../player").i_frames) = true
		(get_node("../player").player_hurt_particles())
		(get_node("../player").framefreeze(0.4, 0.3))
	if purple_health < 1:
		queue_free()

func _on_playerdeath_area_entered(area):
	if area.is_in_group("deal 1 damage"):
		var effect := purple_hurt.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		purple_health -= 1
	if area.is_in_group("parry"):
		speed = 0
		$eye_bottom.speed_scale = 0.1
		$Stunned.start()
	if area.is_in_group("deal 2 damage"):
		var effect := purple_hurt.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		purple_health -= 2

func _on_stunned_timeout():
	$eye_bottom.speed_scale = 1.5
	is_stunned = false
	speed = 700

func _on_player_detection_area_entered(area):
	if area.is_in_group("player") and is_stunned == false:
		player = area.get_parent()
		player_chase = true

func _on_player_detection_area_exited(area):
	if area.is_in_group("player"):
		player = null
		player_chase = false

func _on_hurts_player_area_entered(area):
	if area.is_in_group("player"):
		attack_player = true

func _on_hurts_player_area_exited(area):
	if area.is_in_group("player"):
		attack_player = false
