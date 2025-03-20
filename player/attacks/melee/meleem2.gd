extends Node2D

@onready var areaa = $Area2D

var slashes = 0
var slash := preload("res://player/attacks/melee/meleem2_attack.tscn")
var max_dist = 300

func _ready() -> void:
	get_tree().get_first_node_in_group("player").get_parent().connect("died", queue_free)

func _on_slash_timer_timeout() -> void:
	var effect := slash.instantiate()
	effect.position = position
	get_parent().add_child(effect)
	slashes += 1
	if slashes > 4:
		queue_free()

func _process(_delta):
	position = get_node("../player").position
	var mouse_pos = get_local_mouse_position()
	var dir = Vector2.ZERO.direction_to(mouse_pos)
	var dist = mouse_pos.length()
	$Area2D.position = dir * min(dist, max_dist)

func _on_die_timer_timeout() -> void:
	queue_free()

func _on_area_2d_area_entered(area):
	if area.is_in_group("enemy"):
		$SlashTimer.start()
		area.add_to_group("marked melee_m2")

func _on_area_2d_area_exited(area):
	if area.is_in_group("enemy"):
		area.remove_from_group("marked melee_m2")
