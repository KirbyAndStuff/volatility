extends CharacterBody2D

var direction = Vector2.ZERO
var stay_above_player = true
var speed = 3000
var smack_lines := preload("res://bosses/boss_practice/smack_lines.tscn")
var anim_playing = false
var smack_parried = false
var health = 50.0
var guarded = false

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
	if Input.is_action_just_pressed("interact") and anim_playing == false and smack_parried == false:
		smack()
	#if $SmackTimer.is_stopped() and anim_playing == false and smack_parried == false:
		#smack()
	if health < 1:
		get_node("../camera").snap = false
		get_node("../camera").target = get_node("../player")
		get_node("../player/player_hurtbox").add_to_group("snap camera")
		get_node("../camera").const_shake = 0
		queue_free()

func smack():
	$SmackTimer.start()
	anim_playing = true
	$roarsfx.pitch_scale = randf_range(0.7, 0.8)
	$roarsfx.play()
	$about_to_smacksfx.play()
	$arm_left/AnimationPlayer.play("smack_left")
	$arm_right/AnimationPlayer.play("smack_right")
	shake_smack(2.15, 0.05, 1.5, 0.7, -1, 1.75)
	smack_speed(2.1, 1)
	grab_camera(1, 1.5, false, false)
	await get_tree().create_timer(3.7, false).timeout
	if anim_playing:
		shake_smack(1.25, 0.05, 2, 0.6, 1, 1.5)
		$about_to_smacksfx.volume_db = -30
		create_tween().tween_property($about_to_smacksfx, "volume_db", 5, 1)
		$about_to_smacksfx.play()
		await get_tree().create_timer(0.2, false).timeout
		smack_again()

func shake_smack(time1, time2, scale_effect, sfx, loud, speeda):
	get_node("../camera").const_shake = 7.5
	await get_tree().create_timer(time1, false).timeout
	get_node("../camera").const_shake = 0
	get_node("../camera").apply_shake(50, 0.25)
	await get_tree().create_timer(time2, false).timeout
	$about_to_smacksfx.stop()
	if smack_parried == false:
		var effect := smack_lines.instantiate()
		effect.position = position + Vector2(0, 500)
		effect.scale = Vector2(scale_effect, scale_effect)
		effect.sfx = sfx
		effect.loud = loud
		effect.speed = speeda
		get_parent().add_child(effect)

func smack_speed(time1, time2):
	await get_tree().create_timer(time1, false).timeout
	stay_above_player = false
	await get_tree().create_timer(time2, false).timeout
	if smack_parried == false:
		stay_above_player = true

func grab_camera(time1, time2, snap, go_to_player):
	await get_tree().create_timer(time1, false).timeout
	get_node("../camera").snap = snap
	get_node("../camera").target = get_node("camera_anchor")
	$camera_anchor.add_to_group("snap camera")
	if go_to_player:
		await get_tree().create_timer(time2, false).timeout
		get_node("../camera").snap = false
		get_node("../camera").target = get_node("../player")
		get_node("../player/player_hurtbox").add_to_group("snap camera")

func smack_again():
	if anim_playing:
		$arm_left/AnimationPlayer.play("smack_left_again")
		$arm_right/AnimationPlayer.play("smack_right_again")
		smack_speed(1, 1)
		grab_camera(0, 1.5, true, false)
		await get_tree().create_timer(2.3, false).timeout
		if anim_playing:
			shake_smack(1.25, 0.05, 2.5, 0.5, 2, 1.25)
			$about_to_smacksfx.volume_db = -30
			create_tween().tween_property($about_to_smacksfx, "volume_db", 5, 1)
			$about_to_smacksfx.play()
			await get_tree().create_timer(0.2, false).timeout
			smack_again_again()

func smack_again_again():
	if anim_playing:
		$arm_left/AnimationPlayer.play("smack_left_again")
		$arm_right/AnimationPlayer.play("smack_right_again")
		smack_speed(1, 1)
		grab_camera(0, 1.5, true, true)
		await get_tree().create_timer(2.1, false).timeout
		if anim_playing:
			anim_playing = false

func _on_about_to_smacksfx_finished():
	$about_to_smacksfx.play()

func _on_hitbox_left_area_entered(area):
	if area.is_in_group("parry"):
		$arm_left/AnimationPlayer.play("smack_left_parried")
		parried_smack()

func _on_hitbox_right_area_entered(area):
	if area.is_in_group("parry"):
		$arm_right/AnimationPlayer.play("smack_right_parried")
		parried_smack()

func parried_smack():
	anim_playing = false
	smack_parried = true
	stay_above_player = false
	get_node("../camera").snap = false
	get_node("../camera").target = get_node("../player")
	get_node("../player/player_hurtbox").add_to_group("snap camera")
	$body.emitting = false
	$player_death_body/CollisionShape2D.set_deferred("disabled", true)
	$player_death_eye/CollisionShape2D.set_deferred("disabled", false)
	get_node("../camera").failsafe_just_in_case()
	$parriedsfx.play()
	await get_tree().create_timer(2.5, false).timeout
	stay_above_player = true
	smack_parried = false
	$body.emitting = true
	$player_death_body/CollisionShape2D.set_deferred("disabled", false)
	$player_death_eye/CollisionShape2D.set_deferred("disabled", true)

func _on_player_death_body_area_entered(area):
	if area.is_in_group("player_attack"):
		health -= area.get_parent().damage

func _on_player_death_eye_area_entered(area):
	if area.is_in_group("player_attack"):
		health -= area.get_parent().damage * 2
