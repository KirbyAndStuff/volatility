extends Node2D

var direction := Vector2.ZERO
var attack_player = false

func _ready():
	$blast.emitting = true
	get_node("../camera").apply_shake(10, 0.5)
	create_tween().tween_property($Area2D/CollisionPolygon2D, "scale", Vector2(2, 2), 0.5)
	await $blast.finished
	queue_free()

func _process(_delta):
	if attack_player and (get_node("../player").amount_of_i_frames) < 1:
		(get_node("../player").health) -= 1
		(get_node("../player").i_frames(1))
		(get_node("../player").player_hurt_particles())
		(get_node("../player").framefreeze(0.4, 0.3))
	position = get_node("../greater_green").position

func _on_area_2d_area_entered(area):
	if area.is_in_group("player"):
		attack_player = true

func _on_area_2d_area_exited(area):
	if area.is_in_group("player"):
		attack_player = false

func shoot(from: Vector2, to: Vector2):
	global_position = from
	direction = from.direction_to(to)
	rotation = direction.angle()
