extends Node2D

var directiona := Vector2.ZERO

@export var amount: int = 30
@export var bottom: CPUParticles2D
@export var top: CPUParticles2D
@export var timer: float = 0.4

func _ready() -> void:
	bottom.emitting = true
	top.emitting = true
	bottom.amount = amount
	top.amount = amount
	await get_tree().create_timer(timer, false).timeout
	queue_free()

func shoot(from: Vector2, to: Vector2):
	global_position = from
	directiona = from.direction_to(to)
	rotation = directiona.angle()
