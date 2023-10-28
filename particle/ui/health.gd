extends Control

func _process(delta):
	var value = (get_node("../player").health)
	if value < 3:
		$health3.emitting = false
	if value < 2:
		$health3.emitting = false
		$health2.emitting = false
	if value < 1:
		$health3.emitting = false
		$health2.emitting = false
		$health.emitting = false
