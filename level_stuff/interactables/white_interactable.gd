extends CPUParticles2D

var interactable = false
var interacted = false

func _process(_delta):
	if Input.is_action_pressed("interact") and interactable and $Timer.is_stopped():
		if interacted == false:
			var tween = create_tween()
			tween.tween_property(self, "self_modulate", Color(2, 2, 2, 2), 1)
			interacted = true
			$Timer.start()
		else:
			var tween = create_tween()
			tween.tween_property(self, "self_modulate", Color(1, 1, 1, 1), 1)
			interacted = false
			$Timer.start()

func _on_area_2d_area_entered(area):
	if area.is_in_group("player"):
		interactable = true

func _on_area_2d_area_exited(area):
	if area.is_in_group("player"):
		interactable = false
