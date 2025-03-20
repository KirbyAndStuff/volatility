extends Node2D

@onready var child = get_children()[0]

var max_dist = 5

func _process(_delta):
	if get_parent().in_intro == false:
		if $"left eye/AnimationPlayer".is_playing():
			$"left eye/AnimationPlayer".stop()
		var mouse_pos = get_local_mouse_position()
		var dir = Vector2.ZERO.direction_to(mouse_pos)
		var dist = mouse_pos.length()
		child.position = dir * min(dist, max_dist)
	elif $"left eye/AnimationPlayer".is_playing() == false:
		$"left eye/AnimationPlayer".play("left_eye")
