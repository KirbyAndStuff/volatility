extends Area2D

var directiona := Vector2.ZERO

func _ready():
	$CPUParticles2D.emitting = true
	await get_tree().create_timer(0.2).timeout
	queue_free()

func _process(_delta):
	position = get_node("../player").position

func shoot(from: Vector2, to: Vector2):
	global_position = from
	directiona = from.direction_to(to)
	rotation = directiona.angle()
