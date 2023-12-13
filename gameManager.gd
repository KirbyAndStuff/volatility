extends Node2D

var difficulty = 0
var red = preload("res://enemies/red/red.tscn")
var green = preload("res://enemies/green/green.tscn")
var yellow = preload("res://enemies/yellow/yellow.tscn")
var spawn_chances = {"red": 0.1, "green": 0.2, "yellow": 0.15}
var spawn_thresholds = {"red": 0, "green": 3, "yellow": 5}

func _ready():
	# Set up your timers here
	var difficulty_timer = Timer.new()
	difficulty_timer.wait_time = 20
	difficulty_timer.autostart = true
	difficulty_timer.connect("timeout", Callable(self, "_on_difficulty_timer_timeout"))
	add_child(difficulty_timer)

	var spawn_timer = Timer.new()
	spawn_timer.wait_time = 1
	spawn_timer.autostart = true
	spawn_timer.connect("timeout", Callable(self, "_on_spawn_timer_timeout"))
	add_child(spawn_timer)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):  # Default action for ESC key
		if get_tree().paused:
			get_tree().paused = false  # Unpause
			$PauseMenu.hide()  # Assuming PauseMenu is the name of your pause menu node
		else:
			get_tree().paused = true  # Pause
			$PauseMenu.show()

func _on_difficulty_timer_timeout():
	difficulty += 1
	print("Difficulty increased to: ", difficulty)
	# Optionally adjust spawn chances here

func _on_spawn_timer_timeout():
	for enemy_type in spawn_chances.keys():
		if difficulty >= spawn_thresholds[enemy_type]:
			if randf() < spawn_chances[enemy_type]:
				# Spawn the enemy
				spawn_enemy(enemy_type)

func spawn_enemy(type):
	# Load the enemy scene based on the type
	var enemy_scene = load("res://enemies/" + type + "/" + type + ".tscn")
	var enemy_instance = enemy_scene.instantiate()

	# Get the size of the black.bmp (assuming it's set on a Sprite node)
	var background = get_node("../2Os250Kt")
	var size = background.texture.get_size()

	# Generate a random position within the bounds of black.bmp
	var random_x = randf() * size.x
	var random_y = randf() * size.y
	var random_position = Vector2(random_x, random_y)

	# Set the enemy's position and add it to the scene
	enemy_instance.position = random_position
	add_child(enemy_instance)
