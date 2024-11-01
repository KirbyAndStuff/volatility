extends CharacterBody2D

var direction := Vector2.ZERO
var detonation := preload("res://player/attacks/bullet/beam_detonation.tscn")
var hit_wall = false
var damage = 0

@export var speed := 4000.0

func shoot(from: Vector2, to: Vector2):
	global_position = from
	direction = from.direction_to(to)
	rotation = direction.angle()

func _physics_process(delta):
	position += direction * speed * delta

func _on_timer_timeout() -> void:
	$bullet_body.emitting = false
	await get_tree().create_timer(0.3, false).timeout
	var effect := detonation.instantiate()
	effect.position = position
	get_parent().add_child(effect)
	queue_free()

func _on_bullet_hurtbox_body_entered(body):
	if body.is_in_group("wall") and hit_wall == false:
		hit_wall = true
		die()

func _on_bullet_hurtbox_area_entered(area):
	if area.is_in_group("enemy_body"):
		die()
	if area.is_in_group("beam"):
		var effect := detonation.instantiate()
		effect.position = position
		get_parent().call_deferred("add_child", effect)
		queue_free()

func die():
	var effect := detonation.instantiate()
	effect.position = $bullet_body.global_position
	effect.shake = 0
	get_parent().call_deferred("add_child", effect)
	queue_free()
