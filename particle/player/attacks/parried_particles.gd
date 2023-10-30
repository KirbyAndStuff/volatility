extends CharacterBody2D

func _ready():
	$CPUParticles2D.emitting = true

func _on_timer_timeout() -> void:
	queue_free()
