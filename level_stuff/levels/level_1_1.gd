extends Node2D

var level_start = preload("res://level_stuff/interactables/level_start_particle.tscn")
var hurt_player = false
var please_press_m2 = false
var pressed_m2 = false
var red_intro_health = 3
var red_intro_died = false
var checkpoint = null #Vector2(10094, 1072) #null
var checkpoint_number = 0 #7 #0
var restarts = 0
var shot_green_meteor = false #true #false
var room_in_action = null #5_7 #null

var spawned_green_5_2 = false #true #false
var spawned_red_5_2 = false #true #false
var died_to_greater_green = false

func _process(_delta):
	if hurt_player and (get_node("player").amount_of_i_frames) < 1:
		(get_node("player").health) -= 1
		(get_node("player").i_frames(1))
		(get_node("player").player_hurt_particles())
		(get_node("player").framefreeze(0.4, 0.3))

	if get_node("white_interactable").interacted == true:
		red_intro_thing()

	if please_press_m2 and Input.is_action_pressed("right_mouse_button") and get_node("player").gunm2_cooldown > 100:
		pressed_m2 = true
		get_node("player").gunm2_cooldown = 0
		var bullet_scene = preload("res://player/attacks/bullet/bulletm2.tscn")
		var shot = bullet_scene.instantiate()
		shot.shake = 10
		add_child(shot)
		shot.shoot(get_node("player").global_position, get_global_mouse_position())

	if red_intro_health < 1 and red_intro_died == false:
		red_intro_die()
		red_intro_died = true

	if not get_tree().has_group("1-1") and room_in_action == 1_1:
		spawn_first_room_second_wave()
		room_in_action = 0
	if not get_tree().has_group("1-2") and room_in_action == 1_2:
		room_in_action = null
		$first_room.queue_free()
		$barrier_break/barrier_walls.visible = true
		$barrier_break/barrier_walls.process_mode = Node.PROCESS_MODE_INHERIT
		create_tween().tween_property($barrier_break/barrier_walls, "modulate", Color(1, 1, 1, 1), 1)
		$lock_walls1.process_mode = Node.PROCESS_MODE_DISABLED
		create_tween().tween_property($lock_walls1, "modulate", Color(0, 0, 0, 0), 1)
		$lock_walls3.process_mode = Node.PROCESS_MODE_DISABLED
		create_tween().tween_property($lock_walls3, "modulate", Color(0, 0, 0, 0), 1)
		$white_walls2.enabled = true
		create_tween().tween_property($white_walls2, "modulate", Color(1, 1, 1, 1), 1)
		checkpoint_number = 2

	if not get_tree().has_group("hall") and room_in_action == 1_5:
		$hallway_area.queue_free()
		$lock_walls3.process_mode = Node.PROCESS_MODE_DISABLED
		create_tween().tween_property($lock_walls3, "modulate", Color(0, 0, 0, 0), 1)
		room_in_action = null
		checkpoint_number = 3

	if room_in_action == 2_1 and not get_tree().has_group("2-1"):
		spawn_second_room_second_wave()
		room_in_action = 0
	if room_in_action == 2_2 and not get_tree().has_group("2-2"):
		$second_room_area.queue_free()
		$lock_walls3.process_mode = Node.PROCESS_MODE_DISABLED
		create_tween().tween_property($lock_walls3, "modulate", Color(0, 0, 0, 0), 1)
		$hurt_walls2.visible = true
		create_tween().tween_property($hurt_walls2, "modulate", Color(3, 1, 1, 1), 1)
		$white_walls3.enabled = true
		$die_walls.enabled = true
		room_in_action = null
		checkpoint_number = 4
	if room_in_action == 3_1 and not get_tree().has_group("3-1"):
		spawn_red_room_second_wave()
		room_in_action = 0
	if room_in_action == 3_2 and not get_tree().has_group("3-2") and not get_tree().has_group("3-1") and $red_room_area2.process_mode == PROCESS_MODE_DISABLED:
		$red_room_area.queue_free()
		$red_room_area2.queue_free()
		$lock_walls3.process_mode = Node.PROCESS_MODE_DISABLED
		create_tween().tween_property($lock_walls3, "modulate", Color(0, 0, 0, 0), 1)
		room_in_action = null
		checkpoint_number = 5
	if room_in_action == 4_1 and not get_tree().has_group("4-1"):
		$white_walls4.enabled = true
		create_tween().tween_property($white_walls4, "modulate", Color(1, 1, 1, 1), 1)
		$green_meteor_walls2.emitting = false
		$"green_meteor_walls2/8".emitting = false
		$green_meteor_walls2/StaticBody2D/CollisionPolygon2D2.queue_free()
		$green_meteor_die_spawn.queue_free()
		room_in_action = null
		checkpoint_number = 6
		#$lock_walls6.enabled = true
	if room_in_action == 5_1:
		if not get_tree().has_group("5-1 green") and spawned_green_5_2 == false:
			spawn_5_2_wave_green()
			room_in_action = 0
		if not get_tree().has_group("5-1 red") and spawned_red_5_2 == false:
			spawn_5_2_wave_red()
			room_in_action = 0
	if room_in_action == 5_2 and not get_tree().has_group("5-1 green") and not get_tree().has_group("5-1 red"):
		spawn_5_3_wave()
		room_in_action = 0
	if room_in_action == 5_3 and not get_tree().has_group("5-3"):
		add_to_group("ignore enemy")
		room_in_action = 5_4
	if room_in_action == 5_4 and not get_tree().has_group("5-3 green"):
		remove_from_group("ignore enemy")
		add_to_group("spawn")
		$white_walls6.enabled = true
		create_tween().tween_property($white_walls6, "modulate", Color(1, 1, 1, 1), 1)
		$lock_walls7.enabled = true
		create_tween().tween_property($lock_walls7, "modulate", Color(1, 1, 1, 1), 1)
		$lock_walls6.process_mode = Node.PROCESS_MODE_DISABLED
		create_tween().tween_property($lock_walls6, "modulate", Color(0, 0, 0, 0), 1)
		$white_walls2.enabled = false
		$hurt_walls2.enabled = false
		room_in_action = 0
		checkpoint_number = 7
		$"5_1_room".queue_free()
		spawn_5_5_wave()
	if room_in_action == 5_5 and not get_tree().has_group("5-5"):
		add_to_group("ignore enemy")
		room_in_action = 5_6
	if room_in_action == 5_6 and not get_tree().has_group("5-5 shield"):
		remove_from_group("ignore enemy")
		$"5_5_barrier_walls".process_mode = Node.PROCESS_MODE_DISABLED
		create_tween().tween_property($"5_5_barrier_walls", "modulate", Color(0, 0, 0, 0), 1)
		room_in_action = 5_7
	if room_in_action == 5_7 and not get_tree().has_group("5-5 green"):
		$"5_5_trigger".queue_free()
		checkpoint_number = 8
		$"5_5_barrier_walls".queue_free()
		create_tween().tween_property($lock_walls7, "modulate", Color(0, 0, 0, 0), 1)
		$lock_walls7.process_mode = Node.PROCESS_MODE_DISABLED
		$white_walls7.enabled = true
		$lock_walls5.process_mode = Node.PROCESS_MODE_DISABLED
		create_tween().tween_property($lock_walls5, "modulate", Color(0, 0, 0, 0), 1)
		create_tween().tween_property($white_walls7, "modulate", Color(1, 1, 1, 1), 1)
		room_in_action = null
	if room_in_action == 6_1 and not get_tree().has_group("enemy"):
		checkpoint_number = 9
		$greater_green_room.queue_free()
		$lock_walls8.process_mode = Node.PROCESS_MODE_DISABLED
		create_tween().tween_property($lock_walls8, "modulate", Color(0, 0, 0, 0), 1)
		room_in_action = null
	if room_in_action == 6_1 and not get_tree().has_group("health_bar") and $ui/bar_dec.modulate == Color(1, 1, 1, 1):
		create_tween().set_trans(Tween.TRANS_EXPO).tween_property($ui/bar_dec, "modulate", Color(1, 1, 1, 0), 1)

	if get_node("ui/gameoverscreen").restarted:
		get_node("ui/gameoverscreen").restarted = false
		delete_enemy_and_spawn(0)
		delete_enemy_and_spawn(0.4)
		restarts += 1
		room_in_action = null
		if checkpoint_number == 1:
			if get_tree().has_group("first room"):
				$first_room.call_deferred("set_process_mode", PROCESS_MODE_INHERIT)
			$lock_walls1.process_mode = Node.PROCESS_MODE_DISABLED
			$lock_walls1.modulate = Color(0, 0, 0, 0)
		if checkpoint_number == 2:
			$lock_walls3.process_mode = Node.PROCESS_MODE_DISABLED
			$lock_walls3.modulate = Color(0, 0, 0, 0)
		if checkpoint_number == 3:
			$lock_walls3.process_mode = Node.PROCESS_MODE_DISABLED
			$lock_walls3.modulate = Color(0, 0, 0, 0)
		if checkpoint_number == 4:
			if get_tree().has_group("red room area2"):
				$red_room_area2/CollisionShape2D.visible = true
				$red_room_area2.call_deferred("set_process_mode", PROCESS_MODE_INHERIT)
			$lock_walls3.process_mode = Node.PROCESS_MODE_DISABLED
			$lock_walls3.modulate = Color(0, 0, 0, 0)
		#if checkpoint_number == 5:
		if checkpoint_number == 6:
			$lock_walls5.modulate = Color(0, 0, 0, 0)
			$lock_walls5.process_mode = Node.PROCESS_MODE_DISABLED
			spawned_green_5_2 = false
			spawned_red_5_2 = false
			remove_from_group("ignore enemy")
			for shield in get_tree().get_nodes_in_group("5-3 shield"):
				shield.queue_free()
		if checkpoint_number == 7:
			remove_from_group("ignore enemy")
			$lock_walls5.enabled = false
			$lock_walls5.modulate = Color(1, 1, 1, 0)
			$"5_5_barrier_walls".process_mode = Node.PROCESS_MODE_INHERIT
			$"5_5_barrier_walls".modulate = Color(0, 1, 0, 1)
			for shield in get_tree().get_nodes_in_group("5-5 shield"):
				shield.queue_free()
		if checkpoint_number == 8:
			if checkpoint == Vector2(10050, -1048):
				died_to_greater_green = true
			$lock_walls8.enabled = false
			$lock_walls8.modulate = Color(1, 1, 1, 0)
			$camera.snap = true
			create_tween().set_trans(Tween.TRANS_EXPO).tween_property($ui/bar_dec, "modulate", Color(1, 1, 1, 0), 1)
			get_node("camera").target = get_node("player")
			get_node("player/player_hurtbox").add_to_group("snap camera")

func _ready():
	Engine.time_scale = 1.0
	$camera.apply_shake(10, 0.5)
	await get_tree().create_timer(0.5, false).timeout
	get_node("player").in_intro = true
	$level_end/start_levelsfx.play()
	var effect := level_start.instantiate()
	effect.position = $level_end.position + Vector2(0, 75)
	get_parent().add_child(effect)
	$player.visible = true
	$player.process_mode = Node.PROCESS_MODE_INHERIT
	
	#white_walls2.enabled = false
	#white_walls2.modulate = Color(1, 1, 1, 0)
	#white_walls3.enabled = false
	#white_walls4.enabled = false
	#white_walls4.modulate = Color(1, 1, 1, 0)
	#white_walls5.enabled = false
	#white_walls5.modulate = Color(1, 1, 1, 0)
	#white_walls6.enabled = false
	#white_walls6.modulate = Color(1, 1, 1, 0)
	
	#$lock_walls5.process = disabled
	#$lock_walls5.modulate = Color(1, 1, 1, 0)

func _on_start_level_area_entered(area):
	if area.is_in_group("player"):
		$level_end.queue_free()
		$start_level.queue_free()
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

func _on_red_intro_area_area_entered(area):
	if area.is_in_group("bulletm2"):
		get_node("camera").apply_shake(10, 1)
		$ui/message.text = ""
		$ui/message2.text = ""
		$red_intro/hurt.play()
		red_intro_health -= 1
		$red_intro.amount -= 50
		if red_intro_health == 2:
			$red_intro/damage.amount = 50
		elif red_intro_health == 1:
			$red_intro/hurt.pitch_scale = 0.45
			$red_intro/damage.lifetime = 1
			$red_intro/damage.speed_scale = 1.5
			$red_intro/damage.amount = 200
		elif red_intro_health == 0:
			$red_intro/hurt.pitch_scale = 0.4
		$red_intro/damage.emitting = true

func red_intro_thing():
	$ui/message.text = ""
	$white_interactable.emitting = false
	$got_interactable.play()
	(get_node("player").is_dead) = true
	(get_node("player").speed) = 0
	$red_spawndec.queue_free()
	$red_spawndec2.queue_free()
	$red_spawndec3.queue_free()
	$red_spawndec4.queue_free()
	get_node("white_interactable").interacted = false
	$white_interactable.emitting = false
	configfilehandler.load_other_weaponsstuff().got_bulletm2 = true
	await get_tree().create_timer(1, false).timeout

	$lock_walls1.process_mode = Node.PROCESS_MODE_INHERIT
	create_tween().tween_property($lock_walls1, "modulate", Color(1, 1, 1, 1), 1)
	$white_interactable.process_mode = Node.PROCESS_MODE_DISABLED
	$lock_walls2.process_mode = Node.PROCESS_MODE_DISABLED
	create_tween().tween_property($lock_walls2, "modulate", Color(0, 0, 0, 0), 1)
	create_tween().set_trans(Tween.TRANS_EXPO).tween_property($camera, "zoom", Vector2(0.75, 0.75), 1)
	await get_tree().create_timer(2, false).timeout

	add_to_group("stop following player")
	create_tween().set_trans(Tween.TRANS_EXPO).tween_property($camera, "position", Vector2(3690, 0), 2)
	await get_tree().create_timer(1, false).timeout
	please_press_m2 = true
	await get_tree().create_timer(3, false).timeout
	if pressed_m2 == false:
		$ui/message.text = "Press " + create_action_list("right_mouse_button")

func red_intro_die():
	$red_intro/die.play()
	please_press_m2 = false
	$red_intro.emitting = false
	$red_intro/death.emitting = true
	$camera.apply_shake(20, 2)
	await get_tree().create_timer(2, false).timeout

	$red_intro/death.emitting = false
	await get_tree().create_timer(2, false).timeout

	var tween = create_tween().set_trans(Tween.TRANS_EXPO)
	tween.tween_property($camera, "position", Vector2($player.global_position.x, $player.global_position.y + 500), 1)
	await get_tree().create_timer(2, false).timeout

	$lock_walls2.process_mode = Node.PROCESS_MODE_INHERIT
	create_tween().tween_property($lock_walls2, "modulate", Color(1, 1, 1, 1), 1)
	$red_spawn.orbit_velocity_min = 1
	$red_spawn.orbit_velocity_max = 1
	$red_spawn.speed_scale = 1
	$red_spawn2.orbit_velocity_min = 1
	$red_spawn2.orbit_velocity_max = 1
	$red_spawn2.speed_scale = 1
	$camera.apply_shake(10, 2.5)
	$reds_spawning.play()
	create_tween().set_trans(Tween.TRANS_EXPO).tween_property($camera, "position", Vector2($player.global_position.x, $player.global_position.y), 1)
	await get_tree().create_timer(1, false).timeout
	remove_from_group("stop following player")
	(get_node("player").is_dead) = false
	(get_node("player").speed) = 700
	await get_tree().create_timer(1, false).timeout
	checkpoint = Vector2(2985, 834)
	checkpoint_number = 1
	$red_spawn.add_to_group("enemy_spawn")
	$red_spawn2.add_to_group("enemy_spawn")
	get_tree().call_group("enemy_spawn", "spawn_enemy")
	$red_intro.queue_free()
	create_tween().tween_property($reds_spawning, "volume_db", -50, 1)
	await get_tree().create_timer(1.1, false).timeout
	if get_tree().has_group("enemy"):
		room_in_action = 1_1
	$reds_spawning.queue_free()

func _on_interact_message_area_entered(area):
	if area.is_in_group("player"):
		$ui/message.text = "Press " + create_action_list("interact") + " to Interact"
		$interact_message.queue_free()

func _on_reds_spawning_finished() -> void:
	$reds_spawning.play()

func spawna(type, spawn_position, duration, group, delay, rooma):
	var enemy = load("res://enemies/" + type + "/" + type + "_spawn.tscn").instantiate()
	enemy.visible = false
	enemy.process_mode = PROCESS_MODE_DISABLED
	call_deferred("add_child", enemy)
	enemy.add_to_group("spawn")
	enemy.add_to_group(group)
	await get_tree().create_timer(delay, false).timeout
	if is_instance_valid(enemy):
		enemy.visible = true
		enemy.process_mode = PROCESS_MODE_INHERIT
		enemy.position = spawn_position
		enemy.event = group
		await get_tree().create_timer(duration, false).timeout
		if is_instance_valid(enemy):
			enemy.add_to_group("enemy_spawn")
			enemy.spawn_enemy()
			room_in_action = rooma

func spawn(type, spawn_position, duration, group, delay):
	var enemy = load("res://enemies/" + type + "/" + type + "_spawn.tscn").instantiate()
	enemy.visible = false
	enemy.process_mode = PROCESS_MODE_DISABLED
	call_deferred("add_child", enemy)
	enemy.add_to_group("spawn")
	enemy.add_to_group(group)
	await get_tree().create_timer(delay, false).timeout
	if is_instance_valid(enemy):
		enemy.visible = true
		enemy.process_mode = PROCESS_MODE_INHERIT
		enemy.position = spawn_position
		enemy.event = group
		await get_tree().create_timer(duration, false).timeout
		if is_instance_valid(enemy):
			enemy.add_to_group("enemy_spawn")
			enemy.spawn_enemy()

func spawngreen(spawn_position, duration, group, delay, bonus, rooma):
	var green = load("res://enemies/green/green_spawn.tscn").instantiate()
	green.visible = false
	green.process_mode = PROCESS_MODE_DISABLED
	green.can_fire_laser = bonus
	call_deferred("add_child", green)
	green.add_to_group("spawn")
	green.add_to_group(group)
	await get_tree().create_timer(delay, false).timeout
	if is_instance_valid(green):
		green.visible = true
		green.process_mode = PROCESS_MODE_INHERIT
		green.position = spawn_position
		green.event = group
		await get_tree().create_timer(duration, false).timeout
		if is_instance_valid(green):
			green.add_to_group("enemy_spawn")
			green.spawn_enemy()
			room_in_action = rooma

func spawngreena(spawn_position, duration, group, delay, bonus):
	var green = load("res://enemies/green/green_spawn.tscn").instantiate()
	green.visible = false
	green.process_mode = PROCESS_MODE_DISABLED
	green.can_fire_laser = bonus
	call_deferred("add_child", green)
	green.add_to_group("spawn")
	green.add_to_group(group)
	await get_tree().create_timer(delay, false).timeout
	if is_instance_valid(green):
		green.visible = true
		green.process_mode = PROCESS_MODE_INHERIT
		green.position = spawn_position
		green.event = group
		await get_tree().create_timer(duration, false).timeout
		if is_instance_valid(green):
			green.add_to_group("enemy_spawn")
			green.spawn_enemy()

func spawni(type, spawn_position, group):
	var interactable = load("res://level_stuff/interactables/" + type + ".tscn").instantiate()
	call_deferred("add_child", interactable)
	interactable.position = spawn_position
	interactable.event = group

func spawng(event, spawn_position, target, stationary, collision, delay, size):
	await get_tree().create_timer(delay, false).timeout
	var guardian = load("res://enemies/green_guardian/green_guardian.tscn").instantiate()
	guardian.size = size
	guardian.position = spawn_position
	guardian.event = event
	guardian.target = target
	guardian.stationary = stationary
	guardian.layer_and_mask = collision
	call_deferred("add_child", guardian)

func spawn_first_room_first_wave():
	spawna("red", Vector2(3321, 1100), 1, "1-1", 0, 1_1)
	spawna("red", Vector2(4105, 1100), 1, "1-1", 0, 1_1)

func spawn_first_room_second_wave():
	spawna("red", Vector2(3329, 410), 1, "1-2", 1, 1_2)
	spawna("red", Vector2(3717, 360), 1, "1-2", 1.25, 1_2)
	spawna("red", Vector2(4195, 371), 1, "1-2", 1.5, 1_2)

func spawn_second_room_second_wave():
	add_to_group("spawn")
	await get_tree().create_timer(0.5, false).timeout
	remove_from_group("spawn")
	spawna("red", Vector2(2960, 3300), 1, "2-2", 0, 2_2)
	spawna("red", Vector2(3336, 3116), 1, "2-2", 0.1, 2_2)
	spawna("red", Vector2(4181, 3125), 1, "2-2", 0.2, 2_2)
	spawna("red", Vector2(4428, 3308), 1, "2-2", 0.3, 2_2)

func spawn_red_room_second_wave():
	spawna("red", Vector2(5353, 1889), 1, "3-2", 0, 3_2)
	spawna("red", Vector2(5353, 2718), 1, "3-2", 0.1, 3_2)
	spawna("red", Vector2(7792, 1850), 1, "3-2", 0.2, 3_2)
	spawna("red", Vector2(7792, 2729), 1, "3-2", 0.3, 3_2)
	spawna("red", Vector2(5918, 2306), 1, "3-2", 0.4, 3_2)
	spawna("red", Vector2(7251, 2302), 1, "3-2", 0.5, 3_2)

func spawn_5_2_wave_green():
	spawngreena(Vector2(10103, 535), 1, "5-1 green", 0, false)
	spawngreena(Vector2(10106, 1325), 1, "5-1 green", 0, false)
	await get_tree().create_timer(2.1, false).timeout
	if get_tree().has_group("5-1 green"):
		spawned_green_5_2 = true
		if spawned_red_5_2 == true:
			room_in_action = 5_2
		else:
			room_in_action = 5_1

func spawn_5_2_wave_red():
	spawn("red", Vector2(9368, 901), 1, "5-1 red", 0)
	spawn("red", Vector2(10852, 922), 1, "5-1 red", 0)
	await get_tree().create_timer(2.1, false).timeout
	if get_tree().has_group("5-1 red"):
		spawned_red_5_2 = true
		if spawned_green_5_2 == true:
			room_in_action = 5_2
		else:
			room_in_action = 5_1

func spawn_5_3_wave():
	spawni("barrier_break", Vector2(10119, 501), "5-3 shield")
	spawngreen(Vector2(10121, 871), 1, "5-3 green", 0, false, 5_3)
	spawng("5-3 shield", Vector2(10121, 871), "5-3 green", true, 3, 2, 1)
	spawna("red", Vector2(9562, 634), 1, "5-3", 0.1, 5_3)
	spawna("red", Vector2(10804, 606), 1, "5-3", 0.2, 5_3)
	spawna("red", Vector2(9549, 1191), 1, "5-3", 0.3, 5_3)
	spawna("red", Vector2(10817, 1207), 1, "5-3", 0.4, 5_3)

func spawn_5_5_wave():
	$"5_5_barrier_walls".enabled = true
	create_tween().tween_property($"5_5_barrier_walls", "modulate", Color(0, 1, 0, 1), 1)
	await get_tree().create_timer(3, false).timeout
	if is_instance_valid($ui/glowing_attack_mes):
		$ui/glowing_attack_mes.visible = true
		$ui/glowing_attack_mes2.visible = true
	spawngreena(Vector2(8900, 1044), 1, "5-5 green", 1, true)
	spawngreena(Vector2(11325, 1044), 1, "5-5 green", 1, true)
	spawni("barrier_break", Vector2(10070, -34), "5-5 shield")
	await get_tree().create_timer(4.6, false).timeout
	remove_from_group("spawn")
	if is_instance_valid($ui/glowing_attack_mes):
		create_tween().tween_property($ui/glowing_attack_mes, "modulate", Color(1, 1, 1, 0), 1)
		create_tween().tween_property($ui/glowing_attack_mes2, "modulate", Color(1, 1, 1, 0), 1)
	await get_tree().create_timer(1.5, false).timeout
	if is_instance_valid($ui/glowing_attack_mes):
		$ui/glowing_attack_mes.queue_free()
		$ui/glowing_attack_mes2.queue_free()
	await get_tree().create_timer(2.4, false).timeout
	spawngreen(Vector2(9366, -44), 1, "5-5", 0, false, 5_5)
	spawngreen(Vector2(10874, -44), 1, "5-5", 0, false, 5_5)
	spawna("red", Vector2(10076, 248), 1, "5-5 red", 0.5, 5_5)
	spawng("5-5 shield", Vector2(10076, 248), "5-5 red", false, 1, 2.5, 0.5)
	spawna("red", Vector2(9652, 14), 1, "5-5", 0.5, 5_5)
	spawna("red", Vector2(10540, 14), 1, "5-5", 0.5, 5_5)

func spawn_5_5_wave_alt():
	spawngreena(Vector2(8900, 1044), 1, "5-5 green", 1, true)
	spawngreena(Vector2(11325, 1044), 1, "5-5 green", 1, true)
	spawni("barrier_break", Vector2(10070, -34), "5-5 shield")
	await get_tree().create_timer(2, false).timeout
	spawngreen(Vector2(9366, -44), 1, "5-5", 0, false, 5_5)
	spawngreen(Vector2(10874, -44), 1, "5-5", 0, false, 5_5)
	spawna("red", Vector2(10076, 248), 1, "5-5 red", 0.5, 5_5)
	spawng("5-5 shield", Vector2(10076, 248), "5-5 red", false, 1, 2.5, 0.5)
	spawna("red", Vector2(9652, 14), 1, "5-5", 0.5, 5_5)
	spawna("red", Vector2(10540, 14), 1, "5-5", 0.5, 5_5)

func _on_hallway_area_area_entered(area):
	if area.is_in_group("player") and room_in_action == null:
		room_in_action = 0
		checkpoint = Vector2(3682, 1238)
		$lock_walls3.process_mode = Node.PROCESS_MODE_INHERIT
		create_tween().tween_property($lock_walls3, "modulate", Color(1, 1, 1, 1), 1)
		spawna("red", Vector2(3677, 1426), 1, "hall", 0, 1_5)
		spawna("red", Vector2(3681, 2776), 1, "hall", 0.25, 1_5)

func _on_second_room_area_area_entered(area):
	if area.is_in_group("player") and room_in_action == null:
		room_in_action = 0
		checkpoint = Vector2(3680, 2875)
		$lock_walls3.process_mode = Node.PROCESS_MODE_INHERIT
		create_tween().tween_property($lock_walls3, "modulate", Color(1, 1, 1, 1), 1)
		spawna("red", Vector2(2964, 3210), 1, "2-1", 0, 2_1)
		spawna("red", Vector2(3696, 3588), 1, "2-1", 0.25, 2_1)
		spawna("red", Vector2(4487, 3179), 1, "2-1", 0.25, 2_1)

func _on_red_room_area_area_entered(area):
	if area.is_in_group("player") and room_in_action == null:
		room_in_action = 0
		checkpoint = Vector2(4966, 2316)
		$white_walls1.enabled = false
		create_tween().tween_property($lock_walls4, "modulate", Color(1, 1, 1, 1), 1)
		$lock_walls4.process_mode = Node.PROCESS_MODE_INHERIT
		$lock_walls3.process_mode = Node.PROCESS_MODE_INHERIT
		create_tween().tween_property($lock_walls3, "modulate", Color(1, 1, 1, 1), 1)
		spawna("red", Vector2(5439, 1912), 1, "3-1", 0, 3_1)
		spawna("red", Vector2(6222, 1912), 1, "3-1", 0.1, 3_1)
		spawna("red", Vector2(5439, 2685), 1, "3-1", 0.2, 3_1)
		spawna("red", Vector2(6222, 2685), 1, "3-1", 0.3, 3_1)

func _on_red_room_area_2_area_entered(area):
	if area.is_in_group("player") and $red_room_area2/CollisionShape2D.visible == true:
		$red_room_area2/CollisionShape2D.visible = false
		spawn("red", Vector2(6990, 1863), 1, "3-1", 0)
		spawn("red", Vector2(7754, 1846), 1, "3-1", 0.1)
		spawn("red", Vector2(7783, 2737), 1, "3-1", 0.2)
		spawn("red", Vector2(7053, 2811), 1, "3-1", 0.3)
		await get_tree().create_timer(2.2, false).timeout
		if get_tree().has_group("3-1"):
			$red_room_area2.call_deferred("set_process_mode", PROCESS_MODE_DISABLED)

func _on_first_room_area_entered(area):
	if area.is_in_group("player") and restarts > 0:
		$first_room.call_deferred("set_process_mode", PROCESS_MODE_DISABLED)
		$lock_walls1.process_mode = Node.PROCESS_MODE_INHERIT
		create_tween().tween_property($lock_walls1, "modulate", Color(1, 1, 1, 1), 1)
		spawn_first_room_first_wave()

func delete_enemy_and_spawn(duration):
	await get_tree().create_timer(duration, false).timeout
	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.queue_free()
	for spawnq in get_tree().get_nodes_in_group("spawn"):
		spawnq.queue_free()
	for enemy_attack in get_tree().get_nodes_in_group("enemy_attack"):
		enemy_attack.queue_free()

func _on_green_meteor_area_entered(area):
	if area.is_in_group("player") or area.is_in_group("enemy"):
		if shot_green_meteor == false:
			shot_green_meteor = true
			var green_meteor = preload("res://level_stuff/interactables/green_meteor.tscn")
			var shot = green_meteor.instantiate()
			call_deferred("add_child", shot)
			shot.shoot(Vector2(10000, 235), Vector2(10700, 2460))

func _on_green_meteor_red_area_entered(area):
	if area.is_in_group("player"):
		$green_meteor_red.queue_free()
		checkpoint = Vector2(8167, 2333)
		$lock_walls3.process_mode = Node.PROCESS_MODE_INHERIT
		create_tween().tween_property($lock_walls3, "modulate", Color(1, 1, 1, 1), 1)
		add_to_group("stop following player")
		create_tween().set_trans(Tween.TRANS_EXPO).tween_property($camera, "zoom", Vector2(0.75, 0.75), 1)
		create_tween().set_trans(Tween.TRANS_EXPO).tween_property($camera, "position", Vector2(10000, 2312), 1)
		$red_cutscene.visible = true
		$red_cutscene.process_mode = Node.PROCESS_MODE_INHERIT
		$red_cutscene.get_node("Area2D").add_to_group("enemy")
		$red_cutscene2.visible = true
		$red_cutscene2.process_mode = Node.PROCESS_MODE_INHERIT
		$red_cutscene2.get_node("Area2D").add_to_group("enemy")
		await get_tree().create_timer(1, false).timeout
		$camera.apply_shake(5, 2)
		$green_meteor_coming.play()
		create_tween().tween_property($green_meteor_coming, "volume_db", 10, 1)

func _on_kill_green_meteor_area_entered(area):
	if area.is_in_group("green meteor"):
		room_in_action = 0
		$camera.apply_shake(30, 1.5)
		get_node("player").speed = 0
		get_node("player").player_hurt_particles()
		if is_instance_valid($red_cutscene):
			get_node("red_cutscene").die()
		if is_instance_valid($red_cutscene2):
			get_node("red_cutscene2").die()
		$die_walls.queue_free()
		$green_meteor_coming.stop()
		$green_meteor_die.play()
		$green_meteor_walls2.visible = true
		$green_meteor_walls3.visible = true
		await get_tree().create_timer(3, false).timeout
		$green_meteor_walls2/give_life.play()
		$"green_meteor_walls2/10".emitting = true
		await get_tree().create_timer(0.5, false).timeout
		spawngreen(Vector2(10496, 2239), 3, "4-1", 0, false, 4_1)
		$green_meteor_walls2/give_birth.play()
		$"green_meteor_walls2/11".emitting = true
		$green_meteor_walls3/give_life.play()
		$"green_meteor_walls3/10".emitting = true
		await get_tree().create_timer(0.5, false).timeout
		spawngreen(Vector2(10498, 2372), 3, "4-1", 0, false, 4_1)
		$green_meteor_walls3/give_birth.play()
		$"green_meteor_walls3/11".emitting = true
		create_tween().set_trans(Tween.TRANS_EXPO).tween_property($camera, "position", $player.position, 1)
		await get_tree().create_timer(1, false).timeout
		get_node("player").speed = 700
		remove_from_group("stop following player")

func _on_green_meteor_coming_finished() -> void:
	$green_meteor_coming.play()

func _on_green_meteor_die_spawn_area_entered(area):
	if area.is_in_group("player") and $green_meteor_walls2.visible == true and room_in_action == null:
		room_in_action = 0
		spawngreen(Vector2(10496, 2239), 1, "4-1", 0, false, 4_1)
		spawngreen(Vector2(10498, 2372), 1, "4-1", 0.5, false, 4_1)

func _on__activate_area_entered(area):
	if area.is_in_group("player"):
		$white_walls5.enabled = true
		create_tween().tween_property($white_walls5, "modulate", Color(1, 1, 1, 1), 1)
		$lock_walls6.enabled = true
		create_tween().tween_property($lock_walls6, "modulate", Color(1, 1, 1, 1), 1)
		checkpoint = Vector2(10113, 1578)
		$"5_activate".queue_free()

func _on__1_room_area_entered(area):
	if area.is_in_group("player") and room_in_action == null:
		room_in_action = 0
		create_tween().tween_property($lock_walls5, "modulate", Color(1, 1, 1, 1), 1)
		$lock_walls5.process_mode = Node.PROCESS_MODE_INHERIT
		spawngreen(Vector2(9413, 1261), 1, "5-1 green", 0, false, 5_1)
		spawngreen(Vector2(10897, 1286), 1, "5-1 green", 0, false, 5_1)
		spawna("red", Vector2(10892, 615), 1, "5-1 red", 0, 5_1)
		spawna("red", Vector2(9429, 635), 1, "5-1 red", 0, 5_1)

func _on_greater_green_room_area_entered(area):
	if area.is_in_group("player") and room_in_action == null:
		if died_to_greater_green == false:
			room_in_action = 0
			checkpoint = Vector2(10050, -1048)
			$lock_walls8.enabled = true
			create_tween().tween_property($lock_walls8, "modulate", Color(1, 1, 1, 1), 1)
			create_tween().set_trans(Tween.TRANS_EXPO).tween_property($camera, "zoom", Vector2(0.75, 0.75), 1)
			await get_tree().create_timer(1, false).timeout
			greater_green_intro1()
			await get_tree().create_timer(2, false).timeout
			greater_green_intro2()
			await get_tree().create_timer(8, false).timeout
			greater_green_intro3()
		else:
			$lock_walls8.enabled = true
			create_tween().tween_property($lock_walls8, "modulate", Color(1, 1, 1, 1), 1)
			var enemy = load("res://enemies/greater_green/greater_green.tscn").instantiate()
			enemy.position = Vector2(10033, -2004)
			enemy.play_intro = false
			enemy.add_to_group("6-2")
			call_deferred("add_child", enemy)
			var bar = load("res://enemies/general/enemy_health_bar.tscn").instantiate()
			bar.position = Vector2(960, 160)
			bar.event = "6-2"
			bar.background_color = Color(0, 0, 0, 0)
			bar.fill_color = Color(0, 1, 0, 1)
			bar.namea = "Greater Green"
			bar.title = ""
			bar.modulate = Color(1, 1, 1, 0)
			$ui.call_deferred("add_child", bar)
			create_tween().set_trans(Tween.TRANS_EXPO).tween_property(bar, "modulate", Color(1, 1, 1, 1), 1)
			create_tween().set_trans(Tween.TRANS_EXPO).tween_property($ui/bar_dec, "modulate", Color(1, 1, 1, 1), 1)
			room_in_action = 6_1

func greater_green_intro1():
	if not room_in_action == null:
		add_to_group("stop following player")
		create_tween().set_trans(Tween.TRANS_EXPO).tween_property($camera, "position", Vector2(10033, -2004), 2)

func greater_green_intro2():
	if not room_in_action == null:
		var enemy = load("res://enemies/greater_green/greater_green.tscn").instantiate()
		enemy.position = Vector2(10033, -2004)
		enemy.play_intro = true
		enemy.add_to_group("6-2")
		call_deferred("add_child", enemy)

func greater_green_intro3():
	if not room_in_action == null:
		remove_from_group("stop following player")
		$camera.snap = false
		$camera.speed = 0
		get_node("camera").target = get_node("player")
		get_node("player/player_hurtbox").add_to_group("snap camera")
		var bar = load("res://enemies/general/enemy_health_bar.tscn").instantiate()
		bar.position = Vector2(960, 160)
		bar.event = "6-2"
		bar.background_color = Color(0, 0, 0, 0)
		bar.fill_color = Color(0, 1, 0, 1)
		bar.namea = "Greater Green"
		bar.title = ""
		bar.modulate = Color(1, 1, 1, 0)
		$ui.call_deferred("add_child", bar)
		create_tween().set_trans(Tween.TRANS_EXPO).tween_property(bar, "modulate", Color(1, 1, 1, 1), 1)
		$ui/bar_dec.visible = true
		create_tween().set_trans(Tween.TRANS_EXPO).tween_property($ui/bar_dec, "modulate", Color(1, 1, 1, 1), 1)
		room_in_action = 6_1

func _on__5_trigger_area_entered(area):
	if area.is_in_group("player") and room_in_action == null and not get_tree().has_group("5_1_room"):
		room_in_action = 0
		spawn_5_5_wave_alt()
		$lock_walls5.enabled = true
		create_tween().tween_property($lock_walls5, "modulate", Color(1, 1, 1, 1), 1)

func create_action_list(get_input):
	var events = InputMap.action_get_events(get_input)
	return events[0].as_text()
