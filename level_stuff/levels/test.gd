extends Node2D

var room = null
var current_room = null
var checkpoint = null
var restarts = 0

func _ready() -> void:
	$ui/gameoverscreen.connect("retry", restart)

func _process(_delta):
	if room == 1_1 and not get_tree().has_group("1-1"):
		$"0/Area2D/CollisionShape2D".disabled = true
		room = 0

func _on_area_2d_area_entered(area):
	if area.is_in_group("player") and not get_tree().has_group("1-1"):
		checkpoint = Vector2(394, 70)
		current_room = 1_1
		spawna("red", Vector2(1407, -209), 1, "1-1", 0, 1_1)
		spawna("red", Vector2(1407, 209), 1.2, "1-1", 0, 1_1)

func spawna(type, spawn_position, duration, group, delay, rooma):
	var enemy = load("res://enemies/" + type + "/" + type + "_spawn.tscn").instantiate()
	enemy.visible = false
	enemy.emitting = false
	enemy.add_to_group("spawn")
	enemy.add_to_group(group)
	await get_tree().create_timer(delay, false).timeout
	call_deferred("add_child", enemy)
	enemy.visible = true
	enemy.emitting = true
	enemy.position = spawn_position
	enemy.event = group
	await get_tree().create_timer(duration, false).timeout
	if is_instance_valid(enemy):
		enemy.add_to_group("enemy_spawn")
		enemy.spawn_enemy()
		room = rooma

func restart():
	room = 0
	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.queue_free()
	for spawn in get_tree().get_nodes_in_group("spawn"):
		spawn.queue_free()
	for enemy_attack in get_tree().get_nodes_in_group("enemy_attack"):
		enemy_attack.queue_free()
	if current_room == 1_1:
		pass
