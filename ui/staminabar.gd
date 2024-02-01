extends Control

var stamina_actual = true

@onready var stamina_thingie := $stamina_thingie

func _process(_delta):
	if stamina_actual == true:
		$stamina_bar2.value = 0 - (get_node("../../player").stamina)
	if (get_node("../../player").stamina_tween == false):
		stamina_actual = false
		$stamina_bar2.value -= 50
		var tween = create_tween()
		tween.tween_property($stamina_bar2, "value", $stamina_bar2.value + 50, 0.075)
		get_node("../../player").stamina_tween = true
		await get_tree().create_timer(0.075).timeout
		stamina_actual = true
		stamina_thingie.start()
	if $stamina_bar2.value > -50:
		var color = Color(1.0, 0.0, 0.0)
		$filling.process_material.set("color", color)
	else:
		var default_color = Color(0, 0.827, 1)
		$filling.process_material.set("color", default_color)
