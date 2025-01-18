extends Node2D

var speed = 1000
var rotate_speed = 0.02
var direction = Vector2.ZERO
var follow_player = false

func _ready() -> void:
	$sfx.pitch_scale = randf_range(0.8, 1)
	$sfx.play()
	await get_tree().create_timer(0.1, false).timeout
	follow_player = true

func _physics_process(delta):
	speed += 5000 * delta
	if follow_player:
		rotate_speed += 0.2 * delta
		direction = lerp(direction, position.direction_to(get_node("../player").position), rotate_speed)
	else:
		speed += 1000 * delta
	position += direction * speed * delta

func _on_area_2d_area_entered(area):
	if area.is_in_group("player") and follow_player:
		$Area2D.queue_free()
		area.get_parent().powered_next_bullet_number += 1
		if area.get_parent().powered_next_bullet_number >= 3:
			area.get_parent().powered_next_bullet_number = 0
			area.get_parent().power_next_bullet()
		$trail.visible = false
		$die.emitting = true
		await $die.finished
		queue_free()

func shoot(from: Vector2, to: Vector2):
	global_position = from
	direction = from.direction_to(to)
	rotation = direction.angle()
