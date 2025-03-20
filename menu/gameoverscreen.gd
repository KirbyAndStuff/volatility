extends Control

signal retry

var has_checkpoint = null
var is_paused = false:
	set(value):
		is_paused = value
		get_tree().paused = is_paused
		visible = is_paused
	get:
		return is_paused

func set_is_paused(value):
	is_paused = value
	get_tree().paused = is_paused
	visible = is_paused

func _on_retry_pressed():
	emit_signal("retry")
	if has_checkpoint and not get_parent().get_parent().checkpoint == null:
		visible = false
		get_node("../../player").heal_cooldown = 0
		get_node("../../player").health = 3
		get_node("../../player").global_position = get_parent().get_parent().checkpoint
		get_node("../../player/body").emitting = true
		get_node("../../player/left eye node/left eye").emitting = true
		get_node("../../player/right eye node/right eye").emitting = true
		create_tween().tween_property(get_node("../../player"), "modulate", Color(1, 1, 1, 1), 0.4)
		await get_tree().create_timer(0.4, false).timeout
		get_node("../../player").speed = 700
		get_node("../../player").is_dead = false
	else:
		get_tree().reload_current_scene()

func _on_quit_to_main_menu_pressed():
	self.is_paused = false
	get_tree().change_scene_to_file("res://start_menu/startmenu.tscn")

func _ready():
	has_checkpoint = check_checkpoint()
	get_node("../../player").connect("took_damage", check_if_dead)

func check_if_dead(value):
	if value < 1:
		visible = true

func check_checkpoint():
	return "checkpoint" in get_parent().get_parent()
