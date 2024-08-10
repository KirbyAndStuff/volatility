extends Node2D

func _ready():
	$CanvasLayer/settings_button/Panel/HSlider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	var audio_settings = configfilehandler.load_audio_settings()
	$CanvasLayer/settings_button/Panel/HSlider.value = min(audio_settings.master_volume, 2.0)

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
	$CanvasLayer/settings_button/Panel.visible = true

func _on_close_button_pressed():
	$CanvasLayer/settings_button/Panel.visible = false

func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))


func _on_h_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		configfilehandler.save_audio_setting("master_volume", $CanvasLayer/settings_button/Panel/HSlider.value)
