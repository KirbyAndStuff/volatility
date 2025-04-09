extends CharacterBody2D

var direction = Vector2.ZERO
var speed = 3000.0
var detonation := preload("res://player/attacks/bullet/beam_detonation.tscn")
var death := preload("res://enemies/greater_green/greater_green_bullet_death.tscn")
var hit = false
var damage = 1

func _physics_process(delta):
	if direction == Vector2.ZERO:
		position += transform.x * speed * delta
	else:
		position += direction * speed * delta

func dead():
	if is_in_group("parried"):
		var effect := detonation.instantiate()
		effect.position = $bullet_body.global_position
		get_parent().call_deferred("add_child", effect)
		queue_free()
	else:
		var effect := death.instantiate()
		effect.position = $bullet_body.global_position
		get_parent().call_deferred("add_child", effect)
		queue_free()

func _on_timer_timeout():
	$bullet_body.emitting = false
	await get_tree().create_timer(0.3, false).timeout
	dead()

func _on_bullet_hurtbox_area_entered(area):
	if area.is_in_group("parry") and not get_tree().has_group("greater green parried"):
		$bullet_hurtbox.add_to_group("parried")
		add_to_group("greater green parried")
		$bullet_body.color = Color(0, 1, 1, 1)
		add_to_group("parried")
		$bullet_hurtbox.add_to_group("player_attack")
		$bullet_hurtbox.add_to_group("player_attack")
		speed += 1500.0
		shoot(global_position, get_global_mouse_position())
	if area.is_in_group("enemy_body") and hit == false and is_in_group("parried"):
		hit = true
		dead()

func _on_bullet_hurtbox_body_entered(body):
	if body.is_in_group("wall") and hit == false:
		hit = true
		dead()

func shoot(from: Vector2, to: Vector2):
	global_position = from
	direction = from.direction_to(to)
	rotation = direction.angle()
