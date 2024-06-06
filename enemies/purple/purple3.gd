extends CharacterBody2D

var purple_hurt := preload("res://enemies/purple/purple_hurt3.tscn")

func _ready():
	await get_tree().create_timer(0.3, false).timeout
	$playerdeath/CollisionShape2D.disabled = false
	$hurts_player/CollisionShape2D.disabled = false

var speed = 700
var attack_player = false
var health = 1
var is_stunned = false
var guarded = false

func _physics_process(_delta):
	var direction = (get_node("../player").position-position).normalized()
	velocity=direction*speed
	move_and_slide()

func _process(_delta):
	if attack_player and (get_node("../player").attackable) == true and is_stunned == false:
		(get_node("../player").health) -= 1
		(get_node("../player").i_frames(1))
		(get_node("../player").player_hurt_particles())
		(get_node("../player").framefreeze(0.4, 0.3))
	if health < 1:
		queue_free()

func _on_playerdeath_area_entered(area):
	if area.is_in_group("player_attack") and guarded == false:
		var effect := purple_hurt.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		health -= area.get_parent().damage
	if area.is_in_group("parry") and guarded == false:
		speed = 0
		$eye.speed_scale = 0.1
		$Stunned.start()

func _on_stunned_timeout():
	$eye.speed_scale = 1
	is_stunned = false
	speed = 700

func _on_hurts_player_area_entered(area):
	if area.is_in_group("player"):
		attack_player = true

func _on_hurts_player_area_exited(area):
	if area.is_in_group("player"):
		attack_player = false
