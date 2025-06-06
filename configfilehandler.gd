extends Node

var config = ConfigFile.new()
const SETTINGS_FILE_PATH = "user://settings.ini"

@onready var framerates = [0, 60, 120, 144, 240, 288]

func _ready():
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		config.set_value("audio", "master_volume", 0)
		config.set_value("audio", "sound_effects", 0)
		config.set_value("audio", "music", 0)
		
		config.set_value("video", "full_screen", false)
		config.set_value("video", "framerate", 0)
		config.set_value("video", "screen_shake", 1.0)
		config.set_value("video", "laser_aim", false)
		
		config.set_value("keybinding", "blue_left", "A")
		config.set_value("keybinding", "blue_right", "D")
		config.set_value("keybinding", "blue_up", "W")
		config.set_value("keybinding", "blue_down", "S")
		config.set_value("keybinding", "left_mouse_button", "mouse_1")
		config.set_value("keybinding", "right_mouse_button", "mouse_2")
		config.set_value("keybinding", "dash", "shift")
		config.set_value("keybinding", "parry", "space")
		config.set_value("keybinding", "interact", "E")
		config.set_value("keybinding", "first_weapon", "1")
		config.set_value("keybinding", "second_weapon", "2")
		config.set_value("keybinding", "switch_variant", "Q")
		
		config.set_value("weapons", "bullet", true)
		config.set_value("weapons", "melee", true)
		
		config.set_value("bullets", "bullet", true)
		config.set_value("bullets", "alt_bullet", true)
		
		config.set_value("melees", "melee", true)
		
		config.set_value("weapon_order", "bullets", ["bullet", "alt_bullet"])
		config.set_value("weapon_order", "melees", ["melee"])
		
		config.set_value("other_weaponstuff", "previously_used_weapon", "bullet")
		config.set_value("other_weaponstuff", "got_bulletm2", true)
		
		config.save(SETTINGS_FILE_PATH)
	else:
		config.load(SETTINGS_FILE_PATH)

func save_audio_setting(key: String, value):
	config.set_value("audio", key, value)
	config.save(SETTINGS_FILE_PATH)

func load_audio_settings():
	var audio_settings = {}
	for key in config.get_section_keys("audio"):
		audio_settings[key] = config.get_value("audio", key)
	return audio_settings

func save_video_settings(key: String, value):
	config.set_value("video", key, value)
	config.save(SETTINGS_FILE_PATH)

func load_video_settings():
	var video_settings = {}
	for key in config.get_section_keys("video"):
		video_settings[key] = config.get_value("video", key)
	return video_settings

func save_keybinding(action: StringName, event: InputEvent):
	var event_str
	if event is InputEventKey:
		event_str = OS.get_keycode_string(event.physical_keycode)
	elif event is InputEventMouseButton:
		event_str = "mouse_" + str(event.button_index)
	
	config.set_value("keybinding", action, event_str)
	config.save(SETTINGS_FILE_PATH)

func load_keybindings():
	var keybindings = {}
	var keys = config.get_section_keys("keybinding")
	for key in keys:
		var input_event
		var event_str = config.get_value("keybinding", key)
		
		if event_str.contains("mouse_"):
			input_event = InputEventMouseButton.new()
			input_event.button_index = int(event_str.split("_")[1])
		else:
			input_event = InputEventKey.new()
			input_event.keycode = OS.find_keycode_from_string(event_str)
		
		keybindings[key] = input_event
	return keybindings

func save_weapons(key: String, value):
	config.set_value("weapons", key, value)
	config.save(SETTINGS_FILE_PATH)

func load_weapons():
	var weapon_settings = {}
	for key in config.get_section_keys("weapons"):
		weapon_settings[key] = config.get_value("weapons", key)
	return weapon_settings

func save_bullets(key: String, value):
	config.set_value("bullets", key, value)
	config.save(SETTINGS_FILE_PATH)

func load_bullets():
	var bullet_settings = {}
	for key in config.get_section_keys("bullets"):
		bullet_settings[key] = config.get_value("bullets", key)
	return bullet_settings

func save_melees(key: String, value):
	config.set_value("bullets", key, value)
	config.save(SETTINGS_FILE_PATH)

func load_melees():
	var melee_settings = {}
	for key in config.get_section_keys("melees"):
		melee_settings[key] = config.get_value("melees", key)
	return melee_settings

func save_weapon_order(key: String, value):
	config.set_value("weapon_order", key, value)
	config.save(SETTINGS_FILE_PATH)

func load_weapon_order():
	var weapon_order_settings = {}
	for key in config.get_section_keys("weapon_order"):
		weapon_order_settings[key] = config.get_value("weapon_order", key)
	return weapon_order_settings

func save_other_weaponstuff(key: String, value):
	config.set_value("other_weaponstuff", key, value)
	config.save(SETTINGS_FILE_PATH)

func load_other_weaponsstuff():
	var other_weaponstuff_settings = {}
	for key in config.get_section_keys("other_weaponstuff"):
		other_weaponstuff_settings[key] = config.get_value("other_weaponstuff", key)
	return other_weaponstuff_settings
