extends Node2D

@onready var child = get_children()[0]

var max_dist = 5

func _process(_delta):
	if get_parent().in_intro == false:
		if $"right eye/AnimationPlayer".is_playing():
			$"right eye/AnimationPlayer".stop()
		var mouse_pos = get_local_mouse_position()
		var dir = Vector2.ZERO.direction_to(mouse_pos)
		var dist = mouse_pos.length()
		child.position = dir * min(dist, max_dist)
	elif $"right eye/AnimationPlayer".is_playing() == false:
		$"right eye/AnimationPlayer".play("right_eye")
