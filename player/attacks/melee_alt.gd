extends Node2D

var activate = false
var slashes = 0
var slash := preload("res://player/attacks/melee_alt_attack.tscn")
var max_dist = 300

func _on_slash_timer_timeout() -> void:
	var effect := slash.instantiate()
	effect.position = position
	get_parent().add_child(effect)
	slashes += 1

func _process(_delta):
	position = get_node("../player").position
	var mouse_pos = get_local_mouse_position()
	var dir = Vector2.ZERO.direction_to(mouse_pos)
	var dist = mouse_pos.length()
	$Area2D.position = dir * min(dist, max_dist)
	if $SlashTimer.is_stopped() and activate:
		$SlashTimer.start()
	if slashes > 4:
		queue_free()

func _on_die_timer_timeout() -> void:
	queue_free()

func _on_area_2d_area_entered(area):
	if area.is_in_group("enemy"):
		activate = true
		area.add_to_group("marked melee alt")

func _on_area_2d_area_exited(area):
	if area.is_in_group("enemy"):
		area.remove_from_group("marked melee alt")
