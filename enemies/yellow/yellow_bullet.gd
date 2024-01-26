extends CharacterBody2D

var direction := Vector2.ZERO
var attack_area : = preload("res://enemies/yellow/attack_area.tscn")

@export var speed := 750.0
var attack_player = false

func shoot(from: Vector2, to: Vector2):
	global_position = from
	direction = from.direction_to(to)
	rotation = direction.angle()

func _physics_process(delta):
	position += direction * speed * delta

func _on_timer_timeout() -> void:
	$bullet_body.emitting = false
	await get_tree().create_timer(0.27).timeout
	var effect := attack_area.instantiate()
	effect.position = position
	get_parent().add_child(effect)
	queue_free()

func _process(_delta):
	if attack_player and (get_node("../player").i_frames) == false and (get_node("../player").dashi_frames) == false:
		(get_node("../player").health) -= 1
		(get_node("../player").i_frames) = true
		(get_node("../player").player_hurt_particles())
		(get_node("../player").framefreeze(0.4, 0.3))

func _on_yellow_bullet_hurtbox_body_entered(body):
	if body.name == "player":
		attack_player = true
	if body.is_in_group("wall"):
		var effect := attack_area.instantiate()
		effect.position = position
		get_parent().call_deferred("add_child", effect)
		queue_free()

func _on_yellow_bullet_hurtbox_body_exited(body):
	if body.name == "player":
		attack_player = false
