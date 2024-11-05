extends CharacterBody2D

var direction = Vector2.ZERO
var speed = 1500
@export var is_left = true
var anim_playing = false
var attack_player = false

func _physics_process(delta):
	if is_left:
		direction = (get_parent().global_position - global_position + Vector2(-500, 150)).normalized()
	if is_left == false:
		direction = (get_parent().global_position - global_position + Vector2(500, 150)).normalized()
	var desired_velocity = direction * speed
	var steering = (desired_velocity - velocity) * delta * 7.5
	velocity += steering
	if Input.is_action_just_pressed("left_mouse_button") and anim_playing == false:
		smack()
	#look_at(get_node("../../player").global_position)
	#look_at(get_parent().global_position)
	#look_at(get_global_mouse_position())
	move_and_slide()

func _process(_delta):
	if attack_player and (get_node("../../player").amount_of_i_frames) < 1:
		(get_node("../../player").health) -= 1
		(get_node("../../player").i_frames(1))
		(get_node("../../player").player_hurt_particles())
		(get_node("../../player").framefreeze(0.4, 0.3))

func smack():
	#create_tween().tween_property(self, "rotation", 90, 1)
	anim_playing = true
	speed = 0
	if is_left:
		$AnimationPlayer.play("smack_left_new")
	else:
		$AnimationPlayer.play("smack_right_new")
	shake_smack()
	smack_parent_speed()
	await  $AnimationPlayer.animation_finished
	anim_playing = false
	speed = 1500

func shake_smack():
	get_node("../../camera").apply_shake(5, 1)
	await get_tree().create_timer(2.15, false).timeout
	get_node("../../camera").apply_shake(10, 0.25)

func smack_parent_speed():
	await get_tree().create_timer(2, false).timeout
	get_parent().speed = 0
	await get_tree().create_timer(1, false).timeout
	get_parent().speed = 3000

func _on_hitbox_left_area_entered(area):
	if area.is_in_group("player"):
		attack_player = true

func _on_hitbox_left_area_exited(area):
	if area.is_in_group("player"):
		attack_player = false

func _on_hitbox_right_area_entered(area):
	if area.is_in_group("player"):
		attack_player = true

func _on_hitbox_right_area_exited(area):
	if area.is_in_group("player"):
		attack_player = false
