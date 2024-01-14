extends CharacterBody2D

var direction := Vector2.ZERO
var bullet_death := preload("res://player/attacks/bullet_death.tscn")

@export var speed := 1500.0

func shoot(from: Vector2, to: Vector2):
	global_position = from
	direction = from.direction_to(to)
	rotation = direction.angle()

func _physics_process(delta):
	position += direction * speed * delta

func _on_timer_timeout() -> void:
	$bullet_body.emitting = false
	await get_tree().create_timer(0.3).timeout
	var effect := bullet_death.instantiate()
	effect.position = position
	get_parent().add_child(effect)
	queue_free()

func _on_bullet_hurtbox_body_entered(body):
	if body.is_in_group("wall"):
		var effect := bullet_death.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		queue_free()
