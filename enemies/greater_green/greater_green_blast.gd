extends Node2D

var direction := Vector2.ZERO
var attack_player = false

func _ready():
	$blast.emitting = true
	create_tween().tween_property($hitbox, "scale", Vector2(1, 1), 0.5)
	get_node("../camera").apply_shake(10, 0.5)
	await $blast.finished
	queue_free()

func _process(_delta):
	position = get_node("../greater_green").position
	if attack_player and (get_node("../player").amount_of_i_frames) < 1:
		(get_node("../player").health) -= 1
		(get_node("../player").i_frames(1))
		(get_node("../player").player_hurt_particles())
		(get_node("../player").framefreeze(0.4, 0.3))

func shoot(from: Vector2, to: Vector2):
	global_position = from
	direction = from.direction_to(to)
	rotation = direction.angle()

func _on_hitbox_area_entered(area):
	if area.is_in_group("player"):
		attack_player = true

func _on_hitbox_area_exited(area):
	if area.is_in_group("player"):
		attack_player = false
