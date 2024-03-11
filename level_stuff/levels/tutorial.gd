extends Node2D

var level_start = preload("res://level_stuff/interactables/level_start_particle.tscn")

func _process(_delta):
	if get_tree().has_group("next level"):
		get_tree().change_scene_to_file("res://level_stuff/levels/level_1.tscn")

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
