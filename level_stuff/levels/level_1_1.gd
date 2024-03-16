extends Node2D

var level_start = preload("res://level_stuff/interactables/level_start_particle.tscn")
var red = preload("res://enemies/red/red_spawn.tscn")
var hurt_player = false
var please_press_m2 = false

func _process(_delta):
	if hurt_player and (get_node("player").attackable) == true:
		(get_node("player").health) -= 1
		(get_node("player").i_frames(3))
		(get_node("player").player_hurt_particles())
		(get_node("player").framefreeze(0.4, 0.3))

	if get_node("white_interactable").interacted == true:
		aaa()

	if please_press_m2 and Input.is_action_pressed("right_mouse_button") and get_node("player").alt_gun_cooldown > 100:
		get_node("player/lasersfx").play()
		var bullet_scene = preload("res://player/attacks/beam.tscn")
		var shot = bullet_scene.instantiate()
		get_parent().add_child(shot)
		shot.shoot($player.global_position, get_global_mouse_position())
		get_node("player").alt_gun_cooldown = 0

func _ready():
	await get_tree().create_timer(0.5, false).timeout
	$level_end/start_levelsfx.play()
	remove_from_group("screen_shake 10")
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
	if area.is_in_group("beam") and $red_intro.emitting == true:
		$red_intro.emitting = false
		please_press_m2 = false
		await get_tree().create_timer(1, false).timeout
		remove_from_group("stop following player")
		var tween = create_tween().set_trans(Tween.TRANS_EXPO)
		tween.tween_property($camera, "position", Vector2($player.global_position), 1)
		await get_tree().create_timer(1, false).timeout
		remove_from_group("not beamable")
		(get_node("player").is_dead) = false
		(get_node("player").speed) = 700
		$red_spawn.emitting = true
		$red_spawn2.emitting = true
		await get_tree().create_timer(1, false).timeout
		add_to_group("spawn enemy")
		remove_from_group("enemy")
		$red_intro.queue_free()

func aaa():
	get_node("white_interactable").interacted = false
	$white_interactable.emitting = false
	await get_tree().create_timer(1, false).timeout
	$white_interactable.process_mode = Node.PROCESS_MODE_DISABLED
	$body_interactable.process_mode = Node.PROCESS_MODE_DISABLED
	create_tween().tween_property($white_interactable/interactable_walls, "modulate", Color(0, 0, 0, 0), 1)
	(get_node("player").is_dead) = true
	(get_node("player").speed) = 0
	add_to_group("enemy")
	await get_tree().create_timer(2, false).timeout
	add_to_group("stop following player")
	create_tween().set_trans(Tween.TRANS_EXPO).tween_property($camera, "position", Vector2(3690, 0), 2)
	await get_tree().create_timer(1, false).timeout
	please_press_m2 = true
