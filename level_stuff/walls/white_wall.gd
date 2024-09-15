extends CPUParticles2D

var screen_size

func _ready():
	screen_size = get_viewport_rect().size

func _on_hide_timeout():
	var location_dif = global_position - get_node("../../player").global_position
	if abs(location_dif.x) > (screen_size.x/2) * 2 || abs(location_dif.y) > (screen_size.y/2) * 2:
		hide()
		#$StaticBody2D/CollisionShape2D.disabled = true
	else:
		show()
		#$StaticBody2D/CollisionShape2D.disabled = false
