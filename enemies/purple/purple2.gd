extends CharacterBody2D

var purple_hurt := preload("res://enemies/purple/purple_hurt2.tscn")
var purple3 := preload("res://enemies/purple/purple3.tscn")
var deathsfx := preload("res://enemies/purple/purple_death2sfx.tscn")

func _ready():
	await get_tree().create_timer(0.3, false).timeout
	$playerdeath/CollisionShape2D.disabled = false
	$hurts_player/CollisionShape2D.disabled = false

var speed = 500
var attack_player = false
var health = 2.0
var is_stunned = false
var guarded = false

func _physics_process(_delta):
	var direction = (get_node("../player").position-position).normalized()
	velocity=direction*speed
	move_and_slide()

func _process(_delta):
	if attack_player and (get_node("../player").amount_of_i_frames) < 1 and is_stunned == false:
		(get_node("../player").health) -= 1
		(get_node("../player").i_frames(1))
		(get_node("../player").player_hurt_particles())
		(get_node("../player").framefreeze(0.4, 0.3))
	if health < 1:
		var effect := deathsfx.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		effect.die(0.6)
		var purple3_1 := purple3.instantiate()
		var purple3_2 := purple3.instantiate()
		
		var offset = Vector2(50, 0)
		purple3_1.position = position - offset
		purple3_2.position = position + offset
		
		get_parent().add_child(purple3_1)
		get_parent().add_child(purple3_2)
		
		queue_free()

func _on_playerdeath_area_entered(area):
	if area.is_in_group("player_attack") and guarded == false:
		var effect := purple_hurt.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		health -= area.get_parent().damage
	if area.is_in_group("parry") and guarded == false:
		speed = 0
		$eye_left.speed_scale = 0.1
		$eye_right.speed_scale = 0.1
		$Stunned.start()

func _on_stunned_timeout():
	$eye_left.speed_scale = 0.75
	$eye_right.speed_scale = 0.75
	is_stunned = false
	speed = 500

func _on_hurts_player_area_entered(area):
	if area.is_in_group("player"):
		attack_player = true

func _on_hurts_player_area_exited(area):
	if area.is_in_group("player"):
		attack_player = false
