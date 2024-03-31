extends Node2D

var direction := Vector2.ZERO

@export var speed := 5000.0

func _physics_process(delta):
	position += direction * speed * delta

func shoot(from: Vector2, to: Vector2):
	global_position = from
	direction = from.direction_to(to)
	rotation = direction.angle()

func _on_area_2d_area_entered(area):
	if area.is_in_group("kill green meteor"):
		speed = 0
		$flame.speed_scale = 1.5
		$body.speed_scale = 7.5
		$flame.emitting = false
		$body.emitting = false
		$green_meteor_die.emitting = true
		await get_tree().create_timer(1, false).timeout
		$green_meteor_die.emitting = false
		await get_tree().create_timer(3, false).timeout
		queue_free()
