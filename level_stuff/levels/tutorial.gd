extends Node2D

var level_start = preload("res://level_stuff/interactables/level_start_particle.tscn")
var death := preload("res://enemies/yellow/yellow_death.tscn")
var hurt := preload("res://enemies/yellow/yellow_hurt.tscn")
var hurt_player = false
var enemy1_health = 2.0
var enemy2_health = 2.0
var enemy3_health = 2.0
var enemy_walls_tweened = false
var killed_enemy1 = false
var killed_enemy2 = false
var killed_enemy3 = false
var messages = [false, false, false, false]
var checkpoint = null
var guarded = false

func _process(_delta):
	if get_tree().has_group("next level"):
		get_tree().change_scene_to_file("res://level_stuff/levels/level_1_1.tscn")
	if hurt_player and (get_node("player").amount_of_i_frames) < 1:
		(get_node("player").health) -= 1
		(get_node("player").i_frames(3))
		(get_node("player").player_hurt_particles())
		(get_node("player").framefreeze(0.4, 0.3))
	if Input.is_action_pressed("left_mouse_button") and not get_tree().has_group("shoot message") and messages[0] == false:
		$ui/particle_message.visible = false
		$ui/message.text = ""
		messages[0] = true
	if Input.is_action_pressed("dash") and not get_tree().has_group("dash message") and messages[1] == false:
		$ui/particle_message.visible = false
		$ui/message.text = ""
		messages[1] = true
	if Input.is_action_pressed("parry") and not get_tree().has_group("parry message") and messages[2] == false:
		$ui/particle_message.visible = false
		$ui/message.text = ""
		messages[2] = true
	if Input.is_action_pressed("left_mouse_button") and not get_tree().has_group("heal message") and messages[3] == false:
		$ui/particle_message.visible = false
		$ui/message.text = ""
		$ui/message2.text = ""
		$ui/message3.text = ""
		messages[3] = true
	if enemy_walls_tweened == false:
		if not get_tree().has_group("enemy_body"):
			create_tween().tween_property($enemy_walls, "modulate", Color(0, 0, 0, 0), 1)
			$enemy_walls.process_mode = Node.PROCESS_MODE_DISABLED
			enemy_walls_tweened = true
	if enemy1_health < 1 and killed_enemy1 == false:
		var effect := death.instantiate()
		effect.position = $heal_enemy.position
		get_parent().add_child(effect)
		$heal_enemy.queue_free()
		$enemy1.queue_free()
		killed_enemy1 = true
	if enemy2_health < 1 and killed_enemy2 == false:
		var effect := death.instantiate()
		effect.position = $heal_enemy2.position
		get_parent().add_child(effect)
		$heal_enemy2.queue_free()
		$enemy2.queue_free()
		killed_enemy2 = true
	if enemy3_health < 1 and killed_enemy3 == false:
		var effect := death.instantiate()
		effect.position = $heal_enemy3.position
		get_parent().add_child(effect)
		$heal_enemy3.queue_free()
		$enemy3.queue_free()
		killed_enemy3 = true

func _ready():
	Engine.time_scale = 1.0
	await get_tree().create_timer(2, false).timeout
	$start_level_chargesfx.play()
	$camera.apply_shake(10, 2)
	await get_tree().create_timer(1, false).timeout
	$start_level_chargesfx.play()
	await get_tree().create_timer(1, false).timeout
	$level_end2/start_levelsfx.play()
	var effect := level_start.instantiate()
	effect.position = $level_end2.position + Vector2(0, 75)
	get_parent().add_child(effect)
	$player.visible = true
	$player.process_mode = Node.PROCESS_MODE_INHERIT
	get_node("player").in_intro = true

func _on_start_level_area_entered(area):
	if area.is_in_group("player"):
		$intro_walls.process_mode = Node.PROCESS_MODE_INHERIT
		var tween = create_tween()
		tween.tween_property($intro_walls, "modulate", Color(1, 1, 1, 1,), 1)
		create_tween().tween_property($ui/health, "modulate", Color(1, 1, 1, 1,), 1)
		create_tween().tween_property($ui/staminabar, "modulate", Color(1, 1, 1, 1,), 1)

func _on_hurt_wall_area_entered(area):
	if area.is_in_group("player"):
		hurt_player = true

func _on_hurt_wall_area_exited(area):
	if area.is_in_group("player"):
		hurt_player = false

func _on_bullet_timer_timeout():
	$explosion_top.emitting = true
	$explosion_bottom.emitting = true
	$bullet_sfx.play()
	var tutorial_bullet = preload("res://level_stuff/interactables/tutorial_bullet.tscn")
	var shot = tutorial_bullet.instantiate()
	add_child(shot)
	shot.shoot(Vector2(2827, -345), Vector2(2828, -345))

func _on_shoot_message_area_entered(area):
	if area.is_in_group("player"):
		$ui/particle_message.visible = true
		$ui/particle_message.scale = Vector2(6.5, 0.75)
		$ui/message.text = "Press M1 to Shoot"
		$shoot_message.queue_free()

func _on_dash_message_area_entered(area):
	if area.is_in_group("player"):
		$ui/particle_message.visible = true
		$ui/particle_message.scale = Vector2(13, 0.75)
		$ui/message.text = "Press Shift to Dash, you cannot get hit while Dashing"
		$dash_message.queue_free()

func _on_parry_message_area_entered(area):
	if area.is_in_group("player"):
		$ui/particle_message.visible = true
		$ui/particle_message.scale = Vector2(5.5, 0.75)
		$ui/message.text = "Press Space to Parry"
		$parry_message.queue_free()

func _on_heal_message_area_entered(area):
	if area.is_in_group("player"):
		$ui/particle_message.position = Vector2(957, 847)
		$ui/particle_message.visible = true
		$ui/particle_message.scale = Vector2(13, 1.5)
		$ui/message.text = "Damaging any Enemy will slowly charge up a Heal"
		$ui/message2.text = "This is the only way to replenish your Health"
		#$ui/message3.text = "Heal"
		$heal_message.queue_free()

func _on_enemy_1_area_entered(area):
	if area.is_in_group("player_attack"):
		var effect := hurt.instantiate()
		effect.position = $heal_enemy.position
		get_parent().add_child(effect)
		enemy1_health -= area.get_parent().damage

func _on_enemy_2_area_entered(area):
	if area.is_in_group("player_attack"):
		var effect := hurt.instantiate()
		effect.position = $heal_enemy2.position
		get_parent().add_child(effect)
		enemy2_health -= area.get_parent().damage

func _on_enemy_3_area_entered(area):
	if area.is_in_group("player_attack"):
		var effect := hurt.instantiate()
		effect.position = $heal_enemy3.position
		get_parent().add_child(effect)
		enemy3_health -= area.get_parent().damage

func _on_area_2d_area_entered(area):
	if area.is_in_group("beam detonation"):
		$breakable_wall.emitting = false
		$breakable_wall.remove_from_group("breakable wall")
		await get_tree().create_timer(1, false).timeout
		$breakable_wall.queue_free()
