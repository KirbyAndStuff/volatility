extends CPUParticles2D

var screen_size

func _ready():
	screen_size = get_viewport_rect().size

func _on_hide_timeout():
	var location_dif = global_position - get_tree().get_first_node_in_group("camera").global_position
	if abs(location_dif.x) > (screen_size.x) || abs(location_dif.y) > (screen_size.y):
		hide()
	else:
		show()
