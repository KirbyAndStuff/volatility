extends Control

var restarted = false
var is_paused = false:
	set(value):
		is_paused = value
		get_tree().paused = is_paused
		visible = is_paused
	get:
		return is_paused

@onready var buttons = [$VBoxContainer/Label, $"VBoxContainer/Resume Game", $"VBoxContainer/Restart Level", $VBoxContainer/Settings, $VBoxContainer/Quit]

func _ready():
	var audio_settings = configfilehandler.load_audio_settings()
	$"VBoxContainer/Settings/Settings Menu/VBoxContainer/HSlider".value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	$"VBoxContainer/Settings/Settings Menu/VBoxContainer/HSlider".value = min(audio_settings.master_volume, 2.0) * 100
	$"VBoxContainer/Settings/Settings Menu/VBoxContainer/sfx".value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("sound_effects")))
	$"VBoxContainer/Settings/Settings Menu/VBoxContainer/sfx".value = min(audio_settings.sound_effects, 2.0) * 100
	$"VBoxContainer/Settings/Settings Menu/VBoxContainer/music".value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("music")))
	$"VBoxContainer/Settings/Settings Menu/VBoxContainer/music".value = min(audio_settings.music, 2.0) * 100
	
	var video_settings = configfilehandler.load_video_settings()
	$"VBoxContainer/Settings/Settings Menu/VBoxContainer/screen_shake".value = video_settings.screen_shake * 100

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") and get_node("../../player").health > 0:
		if $"VBoxContainer/Settings/Settings Menu".visible == true:
			$"VBoxContainer/Settings/Settings Menu".visible = false
			for vol in buttons:
				vol.self_modulate = Color(1, 1, 1, 1)
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
	$"VBoxContainer/Settings/Settings Menu".visible = true
	for vol in buttons:
		vol.self_modulate = Color(0, 0, 0, 0)

func _on_close_setting_pressed() -> void:
	$"VBoxContainer/Settings/Settings Menu".visible = false
	for vol in buttons:
		vol.self_modulate = Color(1, 1, 1, 1)

func _on_h_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		configfilehandler.save_audio_setting("master_volume", $"VBoxContainer/Settings/Settings Menu/VBoxContainer/HSlider".value / 100)

func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value / 100))

func _on_sfx_drag_ended(value_changed: bool) -> void:
	if value_changed:
		configfilehandler.save_audio_setting("sound_effects", $"VBoxContainer/Settings/Settings Menu/VBoxContainer/sfx".value / 100)

func _on_sfx_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("sound_effects"), linear_to_db(value / 100))

func _on_music_drag_ended(value_changed: bool) -> void:
	if value_changed:
		configfilehandler.save_audio_setting("music", $"VBoxContainer/Settings/Settings Menu/VBoxContainer/music".value / 100)

func _on_music_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("music"), linear_to_db(value / 100))

func _on_screen_shake_drag_ended(value_changed: bool) -> void:
	if value_changed:
		configfilehandler.save_video_settings("screen_shake", $"VBoxContainer/Settings/Settings Menu/VBoxContainer/screen_shake".value / 100)

func _on_screen_shake_value_changed(value: float) -> void:
	get_tree().get_first_node_in_group("camera").shake_mult = value / 100
