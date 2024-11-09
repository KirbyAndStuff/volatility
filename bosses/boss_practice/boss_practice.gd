extends CharacterBody2D

var direction = Vector2.ZERO
var stay_above_player = true
var speed = 3000
var smack_lines := preload("res://bosses/boss_practice/smack_lines.tscn")
var anim_playing = false

func _ready():
	$arm_left.position = Vector2(-500, 150)
	$arm_right.position = Vector2(500, 150)
	$arm_left.rotation_degrees = 62.5
	$arm_right.rotation_degrees = -62.5

func _physics_process(delta):
	if stay_above_player:
		direction = (get_node("../player").global_position - global_position + Vector2(0, -500)).normalized()
		var desired_velocity = direction * speed
		var steering = (desired_velocity - velocity) * delta * 7.5
		velocity += steering
		move_and_slide()
	$camera_anchor.global_position = get_node("../player").global_position + Vector2(0, -500)

func _process(_delta):
	if Input.is_action_just_pressed("interact") and anim_playing == false:
		smack()

func smack():
	anim_playing = true
	$arm_left.speed = 0
	$arm_right.speed = 0
	$arm_left/AnimationPlayer.play("smack_left")
	$arm_right/AnimationPlayer.play("smack_right")
	shake_smack()
	smack_speed()
	grab_camera()
	await $arm_left/AnimationPlayer.animation_finished
	anim_playing = false
	$arm_left.speed = 1500
	$arm_right.speed = 1500

func shake_smack():
	get_node("../camera").apply_shake(7.5, 1)
	await get_tree().create_timer(2.15, false).timeout
	get_node("../camera").apply_shake(15, 0.25)
	await get_tree().create_timer(0.05, false).timeout
	var effect := smack_lines.instantiate()
	effect.position = position + Vector2(0, 500)
	get_parent().add_child(effect)

func smack_speed():
	await get_tree().create_timer(2.1, false).timeout
	stay_above_player = false
	await get_tree().create_timer(1, false).timeout
	stay_above_player = true

func grab_camera():
	get_node("../camera").snap = false
	await get_tree().create_timer(1, false).timeout
	get_node("../camera").target = get_node("camera_anchor")
	$camera_anchor.add_to_group("snap camera")
	await get_tree().create_timer(1.5, false).timeout
	get_node("../camera").snap = false
	get_node("../camera").target = get_node("../player")
	get_node("../player/player_hurtbox").add_to_group("snap camera")
