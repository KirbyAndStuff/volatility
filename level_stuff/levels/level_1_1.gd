extends Node2D

var level_start = preload("res://level_stuff/interactables/level_start_particle.tscn")
var red = preload("res://enemies/red/red_spawn.tscn")
var hurt_player = false
var please_press_m2 = false
var red_intro_health = 3
var red_intro_died = false
var pressed_m2 = false
var room_cleared = [false, false]
var room_activated = [false, false, false]

func _process(_delta):
	if hurt_player and (get_node("player").attackable) == true:
		(get_node("player").health) -= 1
		(get_node("player").i_frames(3))
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

	if not get_tree().has_group("reds spawning") and not get_tree().has_group("enemy") and room_activated[0] == false:
		spawn_first_room_second_wave()
		room_activated[0] = true
	if room_activated[0] and room_cleared[0] == false:
		if not get_tree().has_group("spawn") and not get_tree().has_group("enemy"):
			$barrier_break/barrier_walls.process_mode = Node.PROCESS_MODE_INHERIT
			create_tween().tween_property($barrier_break/barrier_walls, "modulate", Color(1, 1, 1, 1), 1)
			$lock_walls1.process_mode = Node.PROCESS_MODE_DISABLED
			create_tween().tween_property($lock_walls1, "modulate", Color(0, 0, 0, 0), 1)
			$lock_walls3.process_mode = Node.PROCESS_MODE_DISABLED
			create_tween().tween_property($lock_walls3, "modulate", Color(0, 0, 0, 0), 1)
			$white_walls2.process_mode = Node.PROCESS_MODE_INHERIT
			create_tween().tween_property($white_walls2, "modulate", Color(1, 1, 1, 1), 1)
			room_cleared[0] = true

	if room_activated[1] and not get_tree().has_group("enemy") and not get_tree().has_group("spawn"):
		$lock_walls3.process_mode = Node.PROCESS_MODE_DISABLED
		create_tween().tween_property($lock_walls3, "modulate", Color(0, 0, 0, 0), 1)
		room_activated[1] = false

	if room_activated[2] and not get_tree().has_group("enemy") and not get_tree().has_group("spawn"):
		spawn_second_room_second_wave()
		room_cleared[1] = true
		room_activated[2] = false
	if room_activated[2] == false and room_cleared[1]:
		if not get_tree().has_group("spawn") and not get_tree().has_group("enemy"):
			$lock_walls3.process_mode = Node.PROCESS_MODE_DISABLED
			create_tween().tween_property($lock_walls3, "modulate", Color(0, 0, 0, 0), 1)

func _ready():
	$camera.apply_shake(10, 0.5)
	await get_tree().create_timer(0.5, false).timeout
	$level_end/start_levelsfx.play()
	var effect := level_start.instantiate()
	effect.position = $level_end.position + Vector2(0, 75)
	get_parent().add_child(effect)
	$player.visible = true
	$player.process_mode = Node.PROCESS_MODE_INHERIT

func _on_start_level_area_entered(area):
	if area.is_in_group("player"):
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
	$red_spawn.add_to_group("enemy_spawn")
	$red_spawn2.add_to_group("enemy_spawn")
	get_tree().call_group("enemy_spawn", "spawn_enemy")
	$red_intro.queue_free()
	create_tween().tween_property($reds_spawning, "volume_db", -50, 1)
	await get_tree().create_timer(1.1, false).timeout
	$reds_spawning.queue_free()

func _on_interact_message_area_entered(area):
	if area.is_in_group("player"):
		$ui/message.text = "Press E to Interact"
		$interact_message.queue_free()

func _on_reds_spawning_finished() -> void:
	$reds_spawning.play()

func spawna(number):
	number.add_to_group("spawn")
	number.process_mode = PROCESS_MODE_INHERIT
	number.emitting = true
	await get_tree().create_timer(1, false).timeout
	number.add_to_group("enemy_spawn")
	get_tree().call_group("enemy_spawn", "spawn_enemy")

func spawn_first_room_second_wave():
	add_to_group("spawn")
	await get_tree().create_timer(1, false).timeout
	remove_from_group("spawn")
	spawna($red_spawn3)
	await get_tree().create_timer(0.25, false).timeout
	spawna($red_spawn4)
	await get_tree().create_timer(0.25, false).timeout
	spawna($red_spawn5)

func spawn_second_room_second_wave():
	add_to_group("spawn")
	await get_tree().create_timer(0.5, false).timeout
	remove_from_group("spawn")
	spawna($red_spawn11)
	await get_tree().create_timer(0.1, false).timeout
	spawna($red_spawn12)
	await get_tree().create_timer(0.1, false).timeout
	spawna($red_spawn13)
	await get_tree().create_timer(0.1, false).timeout
	spawna($red_spawn14)

func _on_hallway_area_area_entered(area):
	if area.is_in_group("player"):
		$hallway_area.queue_free()
		$lock_walls3.process_mode = Node.PROCESS_MODE_INHERIT
		create_tween().tween_property($lock_walls3, "modulate", Color(1, 1, 1, 1), 1)
		spawna($red_spawn6)
		await get_tree().create_timer(0.25, false).timeout
		spawna($red_spawn7)
		room_activated[1] = true

func _on_second_room_area_area_entered(area):
	if area.is_in_group("player"):
		$second_room_area.queue_free()
		$lock_walls3.process_mode = Node.PROCESS_MODE_INHERIT
		create_tween().tween_property($lock_walls3, "modulate", Color(1, 1, 1, 1), 1)
		spawna($red_spawn8)
		await get_tree().create_timer(0.25, false).timeout
		spawna($red_spawn9)
		await get_tree().create_timer(0.25, false).timeout
		spawna($red_spawn10)
		room_activated[2] = true
