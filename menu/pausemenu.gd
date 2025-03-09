extends Control

var restarted = false
var is_paused = false:
	set(value):
		is_paused = value
		get_tree().paused = is_paused
		visible = is_paused
	get:
		return is_paused

func _ready():
	var audio_settings = configfilehandler.load_audio_settings()
	$"Settings Menu/VBoxContainer/HSlider".value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	$"Settings Menu/VBoxContainer/HSlider".value = min(audio_settings.master_volume, 2.0) * 100
	$"Settings Menu/VBoxContainer/sfx".value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("sound_effects")))
	$"Settings Menu/VBoxContainer/sfx".value = min(audio_settings.sound_effects, 2.0) * 100
	$"Settings Menu/VBoxContainer/music".value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("music")))
	$"Settings Menu/VBoxContainer/music".value = min(audio_settings.music, 2.0) * 100
	
	var video_settings = configfilehandler.load_video_settings()
	$"Settings Menu/VBoxContainer/screen_shake".value = video_settings.screen_shake * 100
	$"Settings Menu/full_screen/Button".toggle_mode = video_settings.full_screen
	if video_settings.full_screen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		$"Settings Menu/full_screen/Button/2".visible = true
		$"Settings Menu/full_screen/Button/3".visible = true
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		$"Settings Menu/full_screen/Button/2".visible = false
		$"Settings Menu/full_screen/Button/3".visible = false
	$"Settings Menu/framerate/OptionButton".selected = configfilehandler.framerates.find(video_settings.framerate)
	Engine.max_fps = video_settings.framerate

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") and get_node("../../player").health > 0:
		if $"Settings Menu".visible or $InputSettings.visible:
			if $"Settings Menu".visible:
				$"Settings Menu".visible = false
				$VBoxContainer.visible = true
			if $InputSettings.visible:
				$"Settings Menu".visible = true
				$InputSettings.visible = false
				$close_keybinds_button.visible = false
		else:
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

func _on_settings_pressed():
	$"Settings Menu".visible = true
	$VBoxContainer.visible = false

func _on_close_setting_pressed() -> void:
	$"Settings Menu".visible = false
	$VBoxContainer.visible = true

func _on_h_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		configfilehandler.save_audio_setting("master_volume", $"Settings Menu/VBoxContainer/HSlider".value / 100)

func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value / 100))
	$"Settings Menu/percentage/Label".text = str(roundi(value)) + "%"

func _on_sfx_drag_ended(value_changed: bool) -> void:
	if value_changed:
		configfilehandler.save_audio_setting("sound_effects", $"Settings Menu/VBoxContainer/sfx".value / 100)

func _on_sfx_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("sound_effects"), linear_to_db(value / 100))
	$"Settings Menu/percentage/sfx_label".text = str(roundi(value)) + "%"
	if value == 100:
		$"Settings Menu/reset_buttons/sound_effects".visible = false
	else:
		$"Settings Menu/reset_buttons/sound_effects".visible = true

func _on_music_drag_ended(value_changed: bool) -> void:
	if value_changed:
		configfilehandler.save_audio_setting("music", $"Settings Menu/VBoxContainer/music".value / 100)

func _on_music_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("music"), linear_to_db(value / 100))
	$"Settings Menu/percentage/music_label".text = str(roundi(value)) + "%"
	if value == 100:
		$"Settings Menu/reset_buttons/music".visible = false
	else:
		$"Settings Menu/reset_buttons/music".visible = true

func _on_screen_shake_drag_ended(value_changed: bool) -> void:
	if value_changed:
		configfilehandler.save_video_settings("screen_shake", $"Settings Menu/VBoxContainer/screen_shake".value / 100)

func _on_screen_shake_value_changed(value: float) -> void:
	get_tree().get_first_node_in_group("camera").shake_mult = value / 100
	$"Settings Menu/percentage/screen_shake_label".text = str(roundi(value)) + "%"
	if value == 100:
		$"Settings Menu/reset_buttons/screen_shake".visible = false
	else:
		$"Settings Menu/reset_buttons/screen_shake".visible = true

func _on_button_pressed() -> void:
	$"Settings Menu/full_screen/Button".toggle_mode = !$"Settings Menu/full_screen/Button".toggle_mode
	if $"Settings Menu/full_screen/Button".toggle_mode:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		$"Settings Menu/full_screen/Button/2".visible = true
		$"Settings Menu/full_screen/Button/3".visible = true
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		$"Settings Menu/full_screen/Button/2".visible = false
		$"Settings Menu/full_screen/Button/3".visible = false
	configfilehandler.save_video_settings("full_screen", $"Settings Menu/full_screen/Button".toggle_mode)

func _on_option_button_item_selected(index: int) -> void:
	configfilehandler.save_video_settings("framerate", configfilehandler.framerates[$"Settings Menu/framerate/OptionButton".get_item_index(index)])
	Engine.max_fps = configfilehandler.framerates[$"Settings Menu/framerate/OptionButton".get_item_index(index)]

func _on_keybinds_button_pressed() -> void:
	$"Settings Menu".visible = false
	$InputSettings.visible = true
	$close_keybinds_button.visible = true

func _on_close_keybinds_button_pressed() -> void:
	$"Settings Menu".visible = true
	$InputSettings.visible = false
	$close_keybinds_button.visible = false

func _on_sound_effects_pressed() -> void:
	$"Settings Menu/VBoxContainer/sfx".value = 100
	configfilehandler.save_audio_setting("sound_effects", $"Settings Menu/VBoxContainer/sfx".value / 100)

func _on_music_pressed() -> void:
	$"Settings Menu/VBoxContainer/music".value = 100
	configfilehandler.save_audio_setting("music", $"Settings Menu/VBoxContainer/music".value / 100)

func _on_screen_shake_pressed() -> void:
	$"Settings Menu/VBoxContainer/screen_shake".value = 100
	configfilehandler.save_video_settings("screen_shake", $"Settings Menu/VBoxContainer/screen_shake".value / 100)
