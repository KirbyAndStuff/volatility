extends Node2D

var difficulty = 0
var red = preload("res://enemies/red/red.tscn")
var green = preload("res://enemies/green/green.tscn")
var yellow = preload("res://enemies/yellow/yellow.tscn")
var spawn_chances = {"red": 0.1, "green": 0.2, "yellow": 0.15}
var spawn_thresholds = {"red": 0, "green": 3, "yellow": 5}
var pause_menu

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

	# Define the boundaries based on the provided corner coordinates
	var minX = -2250
	var maxX = 2250
	var minY = -1350
	var maxY = 1350

	# Generate a random position within the defined boundaries
	var random_x = randi() % (maxX - minX + 1) + minX
	var random_y = randi() % (maxY - minY + 1) + minY
	var random_position = Vector2(random_x, random_y)

	# Set the enemy's position and add it to the scene
	enemy_instance.position = random_position
	add_child(enemy_instance)
