extends Node2D

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://start_menu/survival.tscn")

func _on_levels_pressed():
	$CanvasLayer/levels/Panel.visible = !$CanvasLayer/levels/Panel.visible

func _on_level_pressed():
	get_tree().change_scene_to_file("res://level_stuff/levels/level.tscn")

func _on_tutorial_pressed():
	get_tree().change_scene_to_file("res://level_stuff/levels/tutorial.tscn")

func _on_level_11_pressed():
	get_tree().change_scene_to_file("res://level_stuff/levels/level_1_1.tscn")

func _on_playground_pressed():
	get_tree().change_scene_to_file("res://start_menu/world.tscn")

func _on_quit_game_button_pressed():
	get_tree().quit()

func _on_settings_button_pressed():
	$CanvasLayer/settings_button/Panel.visible = !$CanvasLayer/settings_button/Panel.visible
