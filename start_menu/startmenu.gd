extends Node2D

func _ready():
	var audio_settings = configfilehandler.load_audio_settings()
	$CanvasLayer/settings_button/Panel/VBoxContainer/HSlider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	$CanvasLayer/settings_button/Panel/VBoxContainer/HSlider.value = min(audio_settings.master_volume, 2.0) * 100
	$CanvasLayer/settings_button/Panel/VBoxContainer/sfx.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("sound_effects")))
	$CanvasLayer/settings_button/Panel/VBoxContainer/sfx.value = min(audio_settings.sound_effects, 2.0) * 100
	$CanvasLayer/settings_button/Panel/VBoxContainer/music.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("music")))
	$CanvasLayer/settings_button/Panel/VBoxContainer/music.value = min(audio_settings.music, 2.0) * 100
	
	var video_settings = configfilehandler.load_video_settings()
	$CanvasLayer/settings_button/Panel/VBoxContainer/screen_shake.value = video_settings.screen_shake * 100

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
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value / 100))

func _on_h_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		configfilehandler.save_audio_setting("master_volume", $CanvasLayer/settings_button/Panel/VBoxContainer/HSlider.value / 100)

func _on_test_pressed() -> void:
	get_tree().change_scene_to_file("res://level_stuff/levels/test.tscn")

func _on_sfx_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("sound_effects"), linear_to_db(value / 100))

func _on_sfx_drag_ended(value_changed: bool) -> void:
	if value_changed:
		configfilehandler.save_audio_setting("sound_effects", $CanvasLayer/settings_button/Panel/VBoxContainer/sfx.value / 100)

func _on_music_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("music"), linear_to_db(value / 100))

func _on_music_drag_ended(value_changed: bool) -> void:
	if value_changed:
		configfilehandler.save_audio_setting("music", $CanvasLayer/settings_button/Panel/VBoxContainer/music.value / 100)

func _on_screen_shake_value_changed(value: float) -> void:
	pass
	#get_tree().get_first_node_in_group("camera").shake_mult = value / 100

func _on_screen_shake_drag_ended(value_changed: bool) -> void:
	if value_changed:
		configfilehandler.save_video_settings("screen_shake", $CanvasLayer/settings_button/Panel/VBoxContainer/screen_shake.value / 100)
