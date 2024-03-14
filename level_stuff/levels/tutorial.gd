extends Node2D

var level_start = preload("res://level_stuff/interactables/level_start_particle.tscn")
var hurt_player = false

func _process(_delta):
	if get_tree().has_group("next level"):
		get_tree().change_scene_to_file("res://level_stuff/levels/level_1.tscn")
	if hurt_player and (get_node("player").attackable) == true:
		(get_node("player").health) -= 1
		(get_node("player").i_frames(3))
		(get_node("player").player_hurt_particles())
		(get_node("player").framefreeze(0.4, 0.3))

func _ready():
	await get_tree().create_timer(2, false).timeout
	$start_level_chargesfx.play()
	add_to_group("screen_shake 10")
	await get_tree().create_timer(1, false).timeout
	$start_level_chargesfx.play()
	await get_tree().create_timer(1, false).timeout
	$level_end2/start_levelsfx.play()
	remove_from_group("screen_shake 10")
	var effect := level_start.instantiate()
	effect.position = $level_end2.position + Vector2(0, 75)
	get_parent().add_child(effect)
	$player.visible = true
	$player.process_mode = Node.PROCESS_MODE_INHERIT

func _on_start_level_area_entered(_area):
	$intro_walls.process_mode = Node.PROCESS_MODE_INHERIT
	await get_tree().create_timer(1, false).timeout
	var tween = create_tween()
	tween.tween_property($intro_walls, "modulate", Color(1, 1, 1, 1,), 1)

func _on_hurt_wall_area_entered(area):
	if area.is_in_group("player"):
		hurt_player = true

func _on_hurt_wall_area_exited(area):
	if area.is_in_group("player"):
		hurt_player = false

func _on_bullet_timer_timeout():
	$bullet_sfx.play()
	var tutorial_bullet = preload("res://level_stuff/interactables/tutorial_bullet.tscn")
	var shot = tutorial_bullet.instantiate()
	get_parent().add_child(shot)
	shot.shoot(Vector2(2827, -345), Vector2(2828, -345))

func _on_area_2d_area_entered(area):
	if area.is_in_group("deal 3 damage"):
		$breakable_wall.emitting = false
		await get_tree().create_timer(1, false).timeout
		$breakable_wall.process_mode = Node.PROCESS_MODE_DISABLED

func _on_parry_melee_area_area_entered(area):
	if area.is_in_group("parry"):
		$parry_melee.speed_scale = 0.1
		$parry_melee2.speed_scale = 0.1
		$parry_melee_wall/StaticBody2D.process_mode = Node.PROCESS_MODE_DISABLED
		$parry_melee_wall.emitting = false
		await get_tree().create_timer(1.5, false).timeout
		$parry_melee.speed_scale = 1
		$parry_melee2.speed_scale = 1
		$parry_melee_wall/StaticBody2D.process_mode = Node.PROCESS_MODE_INHERIT
		$parry_melee_wall.emitting = true
