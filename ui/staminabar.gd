extends Control

@onready var stamina_thingie := $stamina_thingie

func _process(delta):
	if $stamina_bar2.value <= 100:
		$stamina_bar2.value -= 25 * delta
	if Input.is_action_pressed("dash") and $stamina_bar2.value < 50 and stamina_thingie.is_stopped():
		$stamina_bar2.value += 50
		stamina_thingie.start()
	if $stamina_bar2.value > 50:
		var color = Color(1.0, 0.0, 0.0)
		$filling.process_material.set("color", color)
	else:
		var default_color = Color(0, 0.827, 1)
		$filling.process_material.set("color", default_color)
