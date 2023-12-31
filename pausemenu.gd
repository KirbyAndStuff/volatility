extends Control

var is_paused = false:
	set(value):
		is_paused = value
		get_tree().paused = is_paused
		visible = is_paused
	get:
		return is_paused
		
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		self.is_paused = !is_paused
	
func set_is_paused(value):
	is_paused = value
	get_tree().paused = is_paused
	visible = is_paused


func _on_resume_game_pressed():
	self.is_paused = false

func _on_quit_pressed():
	self.is_paused = false
	get_tree().change_scene_to_file("res://startmenu.tscn")
