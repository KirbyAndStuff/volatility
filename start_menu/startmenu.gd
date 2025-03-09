extends Node2D

@onready var buttons = [$CanvasLayer/start_button, $CanvasLayer/levels, $CanvasLayer/playground, $CanvasLayer/quit_game_button, $CanvasLayer/settings_button, $test]

func _ready():
	var audio_settings = configfilehandler.load_audio_settings()
	$CanvasLayer/Panel/VBoxContainer/HSlider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	$CanvasLayer/Panel/VBoxContainer/HSlider.value = min(audio_settings.master_volume, 2.0) * 100
	$CanvasLayer/Panel/VBoxContainer/sfx.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("sound_effects")))
	$CanvasLayer/Panel/VBoxContainer/sfx.value = min(audio_settings.sound_effects, 2.0) * 100
	$CanvasLayer/Panel/VBoxContainer/music.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("music")))
	$CanvasLayer/Panel/VBoxContainer/music.value = min(audio_settings.music, 2.0) * 100
	
	var video_settings = configfilehandler.load_video_settings()
	$CanvasLayer/Panel/VBoxContainer/screen_shake.value = video_settings.screen_shake * 100
	$CanvasLayer/Panel/full_screen/Button.toggle_mode = video_settings.full_screen
	if video_settings.full_screen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		$"CanvasLayer/Panel/full_screen/Button/2".visible = true
		$"CanvasLayer/Panel/full_screen/Button/3".visible = true
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		$"CanvasLayer/Panel/full_screen/Button/2".visible = false
		$"CanvasLayer/Panel/full_screen/Button/3".visible = false
	$CanvasLayer/Panel/framerate/OptionButton.selected = configfilehandler.framerates.find(video_settings.framerate)
	Engine.max_fps = video_settings.framerate

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if $CanvasLayer/Panel.visible:
			$CanvasLayer/Panel.visible = false
			$TextEdit.modulate = Color(1, 1, 1, 1)
			$TextEdit3.modulate = Color(1, 1, 1, 1)
			$Node2D.modulate = Color(1, 1, 1, 1)
			for i in buttons:
				i.visible = true
		if $InputSettings.visible:
			$CanvasLayer/Panel.visible = true
			$InputSettings.visible = false
			$close_keybinds_button.visible = false

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
	$CanvasLayer/Panel.visible = true
	$Node2D.modulate = Color(1, 1, 1, 0.1)
	for i in buttons:
		i.visible = false

func _on_close_button_pressed():
	$CanvasLayer/Panel.visible = false
	$Node2D.modulate = Color(1, 1, 1, 1)
	for i in buttons:
		i.visible = true

func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value / 100))
	$CanvasLayer/Panel/percentage/Label.text = str(roundi(value)) + "%"

func _on_h_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		configfilehandler.save_audio_setting("master_volume", $CanvasLayer/Panel/VBoxContainer/HSlider.value / 100)

func _on_test_pressed() -> void:
	get_tree().change_scene_to_file("res://level_stuff/levels/test.tscn")

func _on_sfx_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("sound_effects"), linear_to_db(value / 100))
	$CanvasLayer/Panel/percentage/sfx_label.text = str(roundi(value)) + "%"
	if value == 100:
		$CanvasLayer/Panel/reset_buttons/sound_effects.visible = false
	else:
		$CanvasLayer/Panel/reset_buttons/sound_effects.visible = true

func _on_sfx_drag_ended(value_changed: bool) -> void:
	if value_changed:
		configfilehandler.save_audio_setting("sound_effects", $CanvasLayer/Panel/VBoxContainer/sfx.value / 100)

func _on_music_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("music"), linear_to_db(value / 100))
	$CanvasLayer/Panel/percentage/music_label.text = str(roundi(value)) + "%"
	if value == 100:
		$CanvasLayer/Panel/reset_buttons/music.visible = false
	else:
		$CanvasLayer/Panel/reset_buttons/music.visible = true

func _on_music_drag_ended(value_changed: bool) -> void:
	if value_changed:
		configfilehandler.save_audio_setting("music", $CanvasLayer/Panel/VBoxContainer/music.value / 100)

func _on_screen_shake_value_changed(value: float) -> void:
	$CanvasLayer/Panel/percentage/screen_shake_label.text = str(roundi(value)) + "%"
	if value == 100:
		$CanvasLayer/Panel/reset_buttons/screen_shake.visible = false
	else:
		$CanvasLayer/Panel/reset_buttons/screen_shake.visible = true

func _on_screen_shake_drag_ended(value_changed: bool) -> void:
	if value_changed:
		configfilehandler.save_video_settings("screen_shake", $CanvasLayer/Panel/VBoxContainer/screen_shake.value / 100)

func _on_button_pressed() -> void:
	$CanvasLayer/Panel/full_screen/Button.toggle_mode = !$CanvasLayer/Panel/full_screen/Button.toggle_mode
	if $CanvasLayer/Panel/full_screen/Button.toggle_mode:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		$"CanvasLayer/Panel/full_screen/Button/2".visible = true
		$"CanvasLayer/Panel/full_screen/Button/3".visible = true
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		$"CanvasLayer/Panel/full_screen/Button/2".visible = false
		$"CanvasLayer/Panel/full_screen/Button/3".visible = false
	configfilehandler.save_video_settings("full_screen", $CanvasLayer/Panel/full_screen/Button.toggle_mode)

func _on_option_button_item_selected(index: int) -> void:
	configfilehandler.save_video_settings("framerate", configfilehandler.framerates[$CanvasLayer/Panel/framerate/OptionButton.get_item_index(index)])
	Engine.max_fps = configfilehandler.framerates[$CanvasLayer/Panel/framerate/OptionButton.get_item_index(index)]

func _on_keybinds_button_pressed() -> void:
	$CanvasLayer/Panel.visible = false
	$InputSettings.visible = true
	$close_keybinds_button.visible = true

func _on_close_keybinds_button_pressed() -> void:
	$CanvasLayer/Panel.visible = true
	$InputSettings.visible = false
	$close_keybinds_button.visible = false

func _on_sound_effects_pressed() -> void:
	$CanvasLayer/Panel/VBoxContainer/sfx.value = 100
	configfilehandler.save_audio_setting("sound_effects", $CanvasLayer/Panel/VBoxContainer/sfx.value / 100)

func _on_music_pressed() -> void:
	$CanvasLayer/Panel/VBoxContainer/music.value = 100
	configfilehandler.save_audio_setting("music", $CanvasLayer/Panel/VBoxContainer/music.value / 100)

func _on_screen_shake_pressed() -> void:
	$CanvasLayer/Panel/VBoxContainer/screen_shake.value = 100
	configfilehandler.save_video_settings("screen_shake", $CanvasLayer/Panel/VBoxContainer/screen_shake.value / 100)
