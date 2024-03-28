extends Control

var restarted = false
var is_paused = false:
	set(value):
		is_paused = value
		get_tree().paused = is_paused
		visible = is_paused
	get:
		return is_paused
		
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") and get_node("../../player").health > 0:
		self.is_paused = !is_paused
	
func set_is_paused(value):
	is_paused = value
	get_tree().paused = is_paused
	visible = is_paused

func _on_resume_game_pressed():
	self.is_paused = false

func _on_quit_pressed():
	self.is_paused = false
	get_tree().change_scene_to_file("res://start_menu/startmenu.tscn")

func _on_restart_level_pressed():
	self.is_paused = false
	get_tree().reload_current_scene()

func _on_last_checkpoint_pressed():
	self.is_paused = false
	restarted = true
	get_node("../../player").heal_cooldown = 0
	get_node("../../player").health = 3
	get_node("../../player").speed = 0
	get_node("../../player").is_dead = true
	get_node("../../player/body").emitting = false
	get_node("../../player/left eye node/left eye").emitting = false
	get_node("../../player/right eye node/right eye").emitting = false
	get_node("../../player").modulate = Color(0, 0, 0, 0)
	if not get_parent().get_parent().checkpoint == null:
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
