extends Control

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
	
func _process(delta):
	var value = (get_node("../../player").health)
	if value < 1:
		visible = true
		await get_tree().create_timer(0.9).timeout
		self.is_paused = true

func _on_retry_pressed():
	self.is_paused = false
	get_tree().change_scene_to_file("res://survival.tscn")

func _on_quit_to_main_menu_pressed():
	self.is_paused = false
	get_tree().change_scene_to_file("res://startmenu.tscn")
