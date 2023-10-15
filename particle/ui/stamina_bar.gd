extends ProgressBar

@onready var stamina_thingie := $stamina_thingie

func _process(delta):
	if value <= 100:
		value += 25 * delta
		
	if Input.is_action_pressed("dash") and value > 50 and stamina_thingie.is_stopped():
		value -= 50
		stamina_thingie.start()
		
	if value < 50:
		var sb = StyleBoxFlat.new()
		add_theme_stylebox_override("fill", sb)
		sb.bg_color = Color("c80000")
	else:
		var sb = StyleBoxFlat.new()
		add_theme_stylebox_override("fill", sb)
		sb.bg_color = Color("00d3ffc8")
