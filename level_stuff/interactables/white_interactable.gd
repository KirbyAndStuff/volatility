extends CPUParticles2D

var interactable = false
var interacted = false

signal interact(interacted)

func _process(_delta):
	if Input.is_action_pressed("interact") and interactable and $Timer.is_stopped():
		emit_signal("interact", !interacted)
		$Timer.start()

func _on_area_2d_area_entered(area):
	if area.is_in_group("player"):
		interactable = true

func _on_area_2d_area_exited(area):
	if area.is_in_group("player"):
		interactable = false
