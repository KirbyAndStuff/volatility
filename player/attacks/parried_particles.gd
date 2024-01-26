extends CharacterBody2D

func _ready():
	$parried_particles.emitting = true

func _on_timer_timeout() -> void:
	queue_free()
