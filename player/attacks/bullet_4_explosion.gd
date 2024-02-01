extends CPUParticles2D

var directiona := Vector2.ZERO

func _ready():
	emitting = true
	$explosion_top.emitting = true
	$explosion_bottom.emitting = true

func _process(_delta):
	if !emitting:
		queue_free()

func shoot(from: Vector2, to: Vector2):
	global_position = from
	directiona = from.direction_to(to)
	rotation = directiona.angle()
