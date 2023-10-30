extends CharacterBody2D

var direction := Vector2.ZERO
var plbullet_death := preload("res://player/attacks/bullet_death.tscn")

@export var speed := 1500.0

func shoot(from: Vector2, to: Vector2):
	global_position = from
	direction = from.direction_to(to)
	rotation = direction.angle()

func _physics_process(delta):
	position += direction * speed * delta

func _on_timer_timeout() -> void:
	var effect := plbullet_death.instantiate()
	effect.position = position
	get_parent().add_child(effect)
	queue_free()
