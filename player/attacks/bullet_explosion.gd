extends Node2D

var directiona := Vector2.ZERO

func _ready():
	$explosion_top.emitting = true
	$explosion_bottom.emitting = true
	await get_tree().create_timer(0.85, false).timeout
	queue_free()

func shoot(from: Vector2, to: Vector2):
	global_position = from
	directiona = from.direction_to(to)
	rotation = directiona.angle()
