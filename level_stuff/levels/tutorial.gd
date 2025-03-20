extends Node2D

var level_start = preload("res://level_stuff/interactables/level_start_particle.tscn")
var death := preload("res://enemies/yellow/yellow_death.tscn")
var hurt := preload("res://enemies/yellow/yellow_hurt.tscn")
var hurt_player = false
var enemy1_health = 2.0
var enemy2_health = 2.0
var enemy3_health = 2.0
var messages = [false, false, false, false]
var checkpoint = null
var guarded = false

func _process(_delta):
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

func _ready():
	Engine.time_scale = 1.0
	get_node("player").connect("next_level", go_to_next_level)
	await get_tree().create_timer(2, false).timeout
	$start_level_chargesfx.play()
	$camera.apply_shake(10, 2)
	create_tween().set_trans(Tween.TRANS_EXPO).tween_property($ParallaxBackground/Parallax2D, "modulate", Color(1, 1, 1, 1), 2)
	create_tween().set_trans(Tween.TRANS_EXPO).tween_property($ParallaxBackground/Parallax2D2, "modulate", Color(1, 1, 1, 1), 2)
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
		get_node("player").take_damage += 1

func _on_hurt_wall_area_exited(area):
	if area.is_in_group("player"):
		get_node("player").take_damage -= 1

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
		$ui/message.text = "Press " + create_action_list("left_mouse_button") + " to Shoot"
		$shoot_message.queue_free()

func _on_dash_message_area_entered(area):
	if area.is_in_group("player"):
		$ui/particle_message.visible = true
		$ui/particle_message.scale = Vector2(13, 0.75)
		$ui/message.text = "Press " + create_action_list("dash") + " to Dash, you cannot get hit while Dashing"
		$dash_message.queue_free()

func _on_parry_message_area_entered(area):
	if area.is_in_group("player"):
		$ui/particle_message.visible = true
		$ui/particle_message.scale = Vector2(5.5, 0.75)
		$ui/message.text = "Press " + create_action_list("parry") + " to Parry"
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
		enemy1_health -= area.get_parent().damage
		if enemy1_health > 0:
			var effect := hurt.instantiate()
			effect.position = $heal_enemy.position
			get_parent().add_child(effect)
		else:
			if enemy1_health <= 0 and enemy2_health <= 0 and enemy3_health <= 0:
				create_tween().tween_property($enemy_walls, "modulate", Color(0, 0, 0, 0), 1)
				$enemy_walls.process_mode = Node.PROCESS_MODE_DISABLED
			var effect := death.instantiate()
			effect.position = $heal_enemy.position
			get_parent().add_child(effect)
			$heal_enemy.queue_free()
			$enemy1.queue_free()

func _on_enemy_2_area_entered(area):
	if area.is_in_group("player_attack"):
		enemy2_health -= area.get_parent().damage
		if enemy2_health > 0:
			var effect := hurt.instantiate()
			effect.position = $heal_enemy2.position
			get_parent().add_child(effect)
		else:
			if enemy1_health <= 0 and enemy2_health <= 0 and enemy3_health <= 0:
				create_tween().tween_property($enemy_walls, "modulate", Color(0, 0, 0, 0), 1)
				$enemy_walls.process_mode = Node.PROCESS_MODE_DISABLED
			var effect := death.instantiate()
			effect.position = $heal_enemy2.position
			get_parent().add_child(effect)
			$heal_enemy2.queue_free()
			$enemy2.queue_free()

func _on_enemy_3_area_entered(area):
	if area.is_in_group("player_attack"):
		enemy3_health -= area.get_parent().damage
		if enemy3_health > 0:
			var effect := hurt.instantiate()
			effect.position = $heal_enemy3.position
			get_parent().add_child(effect)
		else:
			if enemy1_health <= 0 and enemy2_health <= 0 and enemy3_health <= 0:
				create_tween().tween_property($enemy_walls, "modulate", Color(0, 0, 0, 0), 1)
				$enemy_walls.process_mode = Node.PROCESS_MODE_DISABLED
			var effect := death.instantiate()
			effect.position = $heal_enemy3.position
			get_parent().add_child(effect)
			$heal_enemy3.queue_free()
			$enemy3.queue_free()

func _on_area_2d_area_entered(area):
	if area.is_in_group("beam detonation"):
		$breakable_wall.emitting = false
		$breakable_wall.remove_from_group("breakable wall")
		await get_tree().create_timer(1, false).timeout
		$breakable_wall.queue_free()

func go_to_next_level():
	get_tree().create_tween().tween_property($ui/health, "modulate", Color(1, 1, 1, 0), 1)
	get_tree().create_tween().tween_property($ui/staminabar, "modulate", Color(1, 1, 1, 0), 1)
	await get_tree().create_timer(4.15, false).timeout
	$ui/screen_transition.visible = true
	get_tree().create_tween().tween_property($ui/screen_transition, "color", Color(0, 0, 0, 1.5), 1)
	await get_tree().create_timer(2).timeout
	get_tree().change_scene_to_file("res://level_stuff/levels/level_1_1.tscn")

func create_action_list(get_input):
	var events = InputMap.action_get_events(get_input)
	return events[0].as_text()
