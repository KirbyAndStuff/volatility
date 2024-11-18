extends Node2D

var direction := Vector2.ZERO

func _ready():
	$blast.emitting = true
	get_node("../camera").apply_shake(10, 0.5)
	await $blast.finished
	queue_free()

func _process(_delta):
	position = get_node("../greater_green").position

func shoot(from: Vector2, to: Vector2):
	global_position = from
	direction = from.direction_to(to)
	rotation = direction.angle()
