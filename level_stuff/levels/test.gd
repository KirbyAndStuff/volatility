extends Node2D

var level_start = preload("res://level_stuff/interactables/level_start_particle.tscn")
var room = null
var current_room = null
var checkpoint = null
var restarts = 0

func _ready() -> void:
	#$ui/gameoverscreen.connect("retry", restart)
	print($barrier_break.event)
	Engine.time_scale = 1.0
	$camera.apply_shake(10, 0.5)
	await get_tree().create_timer(0.5, false).timeout
	
	get_node("player").in_intro = true
	$level_end/start_levelsfx.play()
	var effect := level_start.instantiate()
	effect.position = $level_end.position + Vector2(0, 75)
	get_parent().add_child(effect)
	$player.visible = true
	$player.process_mode = Node.PROCESS_MODE_INHERIT

func _process(_delta):
	if room == 1_1 and not get_tree().has_group("1-1"):
		$"0/Area2D/CollisionShape2D".disabled = true
		room = 0

func _physics_process(delta: float) -> void:
	pass
	#$barrier_break.position.x += 100 * delta

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

func _on_start_level_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		$level_end.queue_free()
		$start_level.queue_free()
		create_tween().tween_property($ui/health, "modulate", Color(1, 1, 1, 1,), 1)
		create_tween().tween_property($ui/staminabar, "modulate", Color(1, 1, 1, 1,), 1)


func _on_adasd_area_entered(area: Area2D) -> void:
	if area.is_in_group("level_detect"):
		if area.get_parent().is_in_group("bap"):
			print("aaa")


func _on_adasd_area_exited(area: Area2D) -> void:
	if area.is_in_group("level_detect"):
		if area.get_parent().is_in_group("bap"):
			print("bbb")
