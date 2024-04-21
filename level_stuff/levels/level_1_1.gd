extends Node2D

var level_start = preload("res://level_stuff/interactables/level_start_particle.tscn")
var hurt_player = false
var please_press_m2 = false
var red_intro_health = 3
var red_intro_died = false
var pressed_m2 = false
var room_cleared = [false, false, false]
var room_activated = [false, false, false, false, false]
var checkpoint = Vector2(4966, 2316)
var checkpoint_number = 4
var restarts = 0
var shot_green_meteor = false

func _process(_delta):
	if hurt_player and (get_node("player").attackable) == true:
		(get_node("player").health) -= 1
		(get_node("player").i_frames(1))
		(get_node("player").player_hurt_particles())
		(get_node("player").framefreeze(0.4, 0.3))

	if get_node("white_interactable").interacted == true:
		red_intro_thing()

	if please_press_m2 and Input.is_action_pressed("right_mouse_button") and get_node("player").alt_gun_cooldown > 100:
		$ui/message.text = ""
		pressed_m2 = true
		get_node("player/lasersfx").play()
		var bullet_scene = preload("res://player/attacks/beam.tscn")
		var shot = bullet_scene.instantiate()
		add_child(shot)
		shot.shoot($player.global_position, get_global_mouse_position())
		get_node("player").alt_gun_cooldown = 0

	if red_intro_health < 1 and red_intro_died == false:
		red_intro_die()
		red_intro_died = true

	if not get_tree().has_group("spawn") and not get_tree().has_group("enemy") and room_activated[0] and room_cleared[0] == false:
		spawn_first_room_second_wave()
	if room_activated[0] and room_cleared[0]:
		if not get_tree().has_group("spawn") and not get_tree().has_group("enemy"):
			$first_room.queue_free()
			$barrier_break/barrier_walls.visible = true
			$barrier_break/barrier_walls.process_mode = Node.PROCESS_MODE_INHERIT
			create_tween().tween_property($barrier_break/barrier_walls, "modulate", Color(1, 1, 1, 1), 1)
			$lock_walls1.process_mode = Node.PROCESS_MODE_DISABLED
			create_tween().tween_property($lock_walls1, "modulate", Color(0, 0, 0, 0), 1)
			$lock_walls3.process_mode = Node.PROCESS_MODE_DISABLED
			create_tween().tween_property($lock_walls3, "modulate", Color(0, 0, 0, 0), 1)
			$white_walls2.visible = true
			$white_walls2.process_mode = Node.PROCESS_MODE_INHERIT
			create_tween().tween_property($white_walls2, "modulate", Color(1, 1, 1, 1), 1)
			room_activated[0] = false
			checkpoint_number += 1

	if room_activated[1] and not get_tree().has_group("enemy") and not get_tree().has_group("spawn"):
		$hallway_area.queue_free()
		$lock_walls3.process_mode = Node.PROCESS_MODE_DISABLED
		create_tween().tween_property($lock_walls3, "modulate", Color(0, 0, 0, 0), 1)
		room_activated[1] = false
		checkpoint_number += 1

	if room_activated[2] and room_cleared[1] == false and not get_tree().has_group("enemy") and not get_tree().has_group("spawn"):
		spawn_second_room_second_wave()
	if room_activated[2] and room_cleared[1]:
		if not get_tree().has_group("spawn") and not get_tree().has_group("enemy"):
			$second_room_area.queue_free()
			$lock_walls3.process_mode = Node.PROCESS_MODE_DISABLED
			create_tween().tween_property($lock_walls3, "modulate", Color(0, 0, 0, 0), 1)
			$hurt_walls2.visible = true
			create_tween().tween_property($hurt_walls2, "modulate", Color(3, 1, 1, 1), 1)
			$white_walls3.visible = true
			$white_walls3.process_mode = Node.PROCESS_MODE_INHERIT
			$die_walls.visible = true
			$die_walls.process_mode = Node.PROCESS_MODE_INHERIT
			room_activated[2] = false
			checkpoint_number += 1
	if room_activated[3] and room_cleared[2] == false and not get_tree().has_group("spawn") and not get_tree().has_group("enemy"):
		spawn_red_room_second_wave()
	if room_activated[3] and room_cleared[2] and not get_tree().has_group("spawn") and not get_tree().has_group("enemy") and $red_room_area2.process_mode == PROCESS_MODE_DISABLED:
		$red_room_area.queue_free()
		$red_room_area2.queue_free()
		$lock_walls3.process_mode = Node.PROCESS_MODE_DISABLED
		create_tween().tween_property($lock_walls3, "modulate", Color(0, 0, 0, 0), 1)
		room_activated[3] = false
		checkpoint_number += 1
	if room_activated[4] and not get_tree().has_group("spawn") and not get_tree().has_group("enemy"):
		$green_meteor_die_spawn.queue_free()
		room_activated[4] = false

	if get_node("ui/gameoverscreen").restarted:
		get_node("ui/gameoverscreen").restarted = false
		delete_enemy_and_spawn(0)
		delete_enemy_and_spawn(0.4)
		restarts += 1
		if checkpoint_number == 1:
			room_activated[0] = false
			room_cleared[0] = false
			if get_tree().has_group("first room"):
				$first_room.call_deferred("set_process_mode", PROCESS_MODE_INHERIT)
			$lock_walls1.process_mode = Node.PROCESS_MODE_DISABLED
			$lock_walls1.modulate = Color(0, 0, 0, 0)
		if checkpoint_number == 2:
			room_activated[1] = false
			$lock_walls3.process_mode = Node.PROCESS_MODE_DISABLED
			$lock_walls3.modulate = Color(0, 0, 0, 0)
		if checkpoint_number == 3:
			room_activated[2] = false
			room_cleared[1] = false
			$lock_walls3.process_mode = Node.PROCESS_MODE_DISABLED
			$lock_walls3.modulate = Color(0, 0, 0, 0)
		if checkpoint_number == 4:
			room_activated[3] = false
			room_cleared[2] = false
			if get_tree().has_group("red room area2"):
				$red_room_area2.call_deferred("set_process_mode", PROCESS_MODE_INHERIT)
			$lock_walls3.process_mode = Node.PROCESS_MODE_DISABLED
			$lock_walls3.modulate = Color(0, 0, 0, 0)
		if checkpoint_number == 5:
			room_activated[4] = false

func _ready():
	Engine.time_scale = 1.0
	$camera.apply_shake(10, 0.5)
	await get_tree().create_timer(0.5, false).timeout
	$level_end/start_levelsfx.play()
	var effect := level_start.instantiate()
	effect.position = $level_end.position + Vector2(0, 75)
	get_parent().add_child(effect)
	$player.visible = true
	$player.process_mode = Node.PROCESS_MODE_INHERIT

func _on_start_level_area_entered(area):
	if area.is_in_group("player") and $intro_walls.process_mode == PROCESS_MODE_DISABLED:
		$level_end.queue_free()
		$intro_walls.process_mode = Node.PROCESS_MODE_INHERIT
		var tween = create_tween()
		tween.tween_property($intro_walls, "modulate", Color(1, 1, 1, 1,), 1)

func _on_hurt_wall_area_entered(area):
	if area.is_in_group("player"):
		hurt_player = true

func _on_hurt_wall_area_exited(area):
	if area.is_in_group("player"):
		hurt_player = false

func _on_red_intro_area_area_entered(area):
	if area.is_in_group("beam"):
		$red_intro/hurt.play()
		red_intro_health -= 1
		$red_intro.amount -= 50
		if red_intro_health == 2:
			$red_intro/damage.amount = 50
		else:
			$red_intro/damage.lifetime = 1
			$red_intro/damage.speed_scale = 1.5
			$red_intro/damage.amount = 200
		$red_intro/damage.emitting = true

func red_intro_thing():
	$ui/message.text = ""
	$white_interactable.emitting = false
	(get_node("player").is_dead) = true
	(get_node("player").speed) = 0
	$red_spawndec.queue_free()
	$red_spawndec2.queue_free()
	$red_spawndec3.queue_free()
	$red_spawndec4.queue_free()
	get_node("white_interactable").interacted = false
	$white_interactable.emitting = false
	get_node("/root/player_global").got_beam = true
	await get_tree().create_timer(1, false).timeout

	$lock_walls1.process_mode = Node.PROCESS_MODE_INHERIT
	create_tween().tween_property($lock_walls1, "modulate", Color(1, 1, 1, 1), 1)
	$white_interactable.process_mode = Node.PROCESS_MODE_DISABLED
	$body_interactable.process_mode = Node.PROCESS_MODE_DISABLED
	create_tween().tween_property($white_interactable/interactable_walls, "modulate", Color(0, 0, 0, 0), 1)
	create_tween().set_trans(Tween.TRANS_EXPO).tween_property($camera, "zoom", Vector2(0.75, 0.75), 1)
	await get_tree().create_timer(2, false).timeout

	add_to_group("stop following player")
	create_tween().set_trans(Tween.TRANS_EXPO).tween_property($camera, "position", Vector2(3690, 0), 2)
	await get_tree().create_timer(1, false).timeout
	please_press_m2 = true
	await get_tree().create_timer(3, false).timeout
	if pressed_m2 == false:
		$ui/message.text = "Press Right Click"

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
	remove_from_group("not beamable")
	(get_node("player").is_dead) = false
	(get_node("player").speed) = 700
	await get_tree().create_timer(1, false).timeout
	checkpoint = Vector2(2985, 834)
	checkpoint_number += 1
	$red_spawn.add_to_group("enemy_spawn")
	$red_spawn2.add_to_group("enemy_spawn")
	get_tree().call_group("enemy_spawn", "spawn_enemy")
	$red_intro.queue_free()
	create_tween().tween_property($reds_spawning, "volume_db", -50, 1)
	await get_tree().create_timer(1.1, false).timeout
	room_activated[0] = true
	$reds_spawning.queue_free()

func _on_interact_message_area_entered(area):
	if area.is_in_group("player"):
		$ui/message.text = "Press E to Interact"
		$interact_message.queue_free()

func _on_reds_spawning_finished() -> void:
	$reds_spawning.play()

func spawna(type, spawn_position, duration):
	var enemy = load("res://enemies/" + type + "/" + type + "_spawn.tscn").instantiate()
	call_deferred("add_child", enemy)
	enemy.position = spawn_position
	enemy.add_to_group("spawn")
	await get_tree().create_timer(duration, false).timeout
	if is_instance_valid(enemy):
		enemy.add_to_group("enemy_spawn")
		get_tree().call_group("enemy_spawn", "spawn_enemy")

func spawn_first_room_first_wave():
	spawna("red", Vector2(3321, 1100), 1)
	await get_tree().create_timer(0.25, false).timeout
	spawna("red", Vector2(4105, 1100), 1)
	await get_tree().create_timer(1, false).timeout
	if $first_room.process_mode == PROCESS_MODE_DISABLED:
		room_activated[0] = true

func spawn_first_room_second_wave():
	add_to_group("spawn")
	await get_tree().create_timer(1, false).timeout
	remove_from_group("spawn")
	spawna("red", Vector2(3329, 410), 1)
	await get_tree().create_timer(0.25, false).timeout
	spawna("red", Vector2(3717, 360), 1)
	await get_tree().create_timer(0.25, false).timeout
	spawna("red", Vector2(4195, 371), 1)
	room_cleared[0] = true

func spawn_second_room_second_wave():
	add_to_group("spawn")
	await get_tree().create_timer(0.5, false).timeout
	remove_from_group("spawn")
	spawna("red", Vector2(2960, 3300), 1)
	await get_tree().create_timer(0.1, false).timeout
	spawna("red", Vector2(3336, 3116), 1)
	await get_tree().create_timer(0.1, false).timeout
	spawna("red", Vector2(4181, 3125), 1)
	await get_tree().create_timer(0.1, false).timeout
	spawna("red", Vector2(4428, 3308), 1)
	room_cleared[1] = true

func spawn_red_room_second_wave():
	spawna("red", Vector2(5353, 1889), 1)
	await get_tree().create_timer(0.1, false).timeout
	spawna("red", Vector2(5353, 2718), 1)
	await get_tree().create_timer(0.1, false).timeout
	spawna("red", Vector2(7792, 1850), 1)
	await get_tree().create_timer(0.1, false).timeout
	spawna("red", Vector2(7792, 2729), 1)
	await get_tree().create_timer(0.1, false).timeout
	spawna("red", Vector2(5918, 2306), 1)
	await get_tree().create_timer(0.1, false).timeout
	spawna("red", Vector2(7251, 2302), 1)
	room_cleared[2] = true

func _on_hallway_area_area_entered(area):
	if area.is_in_group("player") and room_activated[1] == false:
		checkpoint = Vector2(3682, 1238)
		room_activated[1] = true
		$lock_walls3.process_mode = Node.PROCESS_MODE_INHERIT
		create_tween().tween_property($lock_walls3, "modulate", Color(1, 1, 1, 1), 1)
		spawna("red", Vector2(3677, 1426), 1)
		await get_tree().create_timer(0.25, false).timeout
		spawna("red", Vector2(3681, 2776), 1)

func _on_second_room_area_area_entered(area):
	if area.is_in_group("player") and room_activated[2] == false:
		checkpoint = Vector2(3680, 2875)
		$lock_walls3.process_mode = Node.PROCESS_MODE_INHERIT
		create_tween().tween_property($lock_walls3, "modulate", Color(1, 1, 1, 1), 1)
		spawna("red", Vector2(2964, 3210), 1)
		await get_tree().create_timer(0.25, false).timeout
		spawna("red", Vector2(3696, 3588), 1)
		await get_tree().create_timer(0.25, false).timeout
		spawna("red", Vector2(4487, 3179), 1)
		if get_tree().has_group("spawn"):
			room_activated[2] = true

func _on_red_room_area_area_entered(area):
	if area.is_in_group("player") and room_activated[3] == false:
		checkpoint = Vector2(4966, 2316)
		$white_walls.visible = false
		$white_walls.process_mode = Node.PROCESS_MODE_DISABLED
		create_tween().tween_property($lock_walls4, "modulate", Color(1, 1, 1, 1), 1)
		$lock_walls4.process_mode = Node.PROCESS_MODE_INHERIT
		$lock_walls3.process_mode = Node.PROCESS_MODE_INHERIT
		create_tween().tween_property($lock_walls3, "modulate", Color(1, 1, 1, 1), 1)
		spawna("red", Vector2(5439, 1912), 1)
		await get_tree().create_timer(0.1, false).timeout
		spawna("red", Vector2(6222, 1912), 1)
		await get_tree().create_timer(0.1, false).timeout
		spawna("red", Vector2(5439, 2685), 1)
		await get_tree().create_timer(0.1, false).timeout
		spawna("red", Vector2(6222, 2685), 1)
		if get_tree().has_group("spawn"):
			room_activated[3] = true

func _on_red_room_area_2_area_entered(area):
	if area.is_in_group("player"):
		$red_room_area2.call_deferred("set_process_mode", PROCESS_MODE_DISABLED)
		spawna("red", Vector2(6990, 1863), 1)
		await get_tree().create_timer(0.1, false).timeout
		spawna("red", Vector2(7754, 1846), 1)
		await get_tree().create_timer(0.1, false).timeout
		spawna("red", Vector2(7783, 2737), 1)
		await get_tree().create_timer(0.1, false).timeout
		spawna("red", Vector2(7053, 2811), 1)

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
	for spawn in get_tree().get_nodes_in_group("spawn"):
		spawn.queue_free()
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
		spawna("green", Vector2(10496, 2239), 3)
		$green_meteor_walls2/give_birth.play()
		$"green_meteor_walls2/11".emitting = true
		$green_meteor_walls3/give_life.play()
		$"green_meteor_walls3/10".emitting = true
		await get_tree().create_timer(0.5, false).timeout
		spawna("green", Vector2(10498, 2372), 3)
		$green_meteor_walls3/give_birth.play()
		$"green_meteor_walls3/11".emitting = true
		create_tween().set_trans(Tween.TRANS_EXPO).tween_property($camera, "position", $player.position, 1)
		await get_tree().create_timer(1, false).timeout
		get_node("player").speed = 700
		remove_from_group("stop following player")
		room_activated[4] = true

func _on_green_meteor_coming_finished() -> void:
	$green_meteor_coming.play()

func _on_green_meteor_die_spawn_area_entered(area):
	if area.is_in_group("player") and $green_meteor_walls2.visible == true:
		if not get_tree().has_group("enemy") and not get_tree().has_group("spawn"):
			spawna("green", Vector2(10496, 2239), 1)
			await get_tree().create_timer(0.5, false).timeout
			spawna("green", Vector2(10498, 2372), 1)
