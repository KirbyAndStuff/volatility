extends CharacterBody2D

var direction := Vector2.ZERO
var detonation := preload("res://player/attacks/bullet/beam_detonation.tscn")
@export var bullet_death : PackedScene
@export var bullet_body : CPUParticles2D
@export var bullet_hitbox : Area2D
var hit_wall = false
var damage = 1

@export var speed := 1000.0

func shoot(from: Vector2, to: Vector2):
	global_position = from
	direction = from.direction_to(to)
	rotation = direction.angle()

func _physics_process(delta):
	position += direction * speed * delta

func _on_timer_timeout() -> void:
	bullet_body.emitting = false
	await get_tree().create_timer(0.27, false).timeout
	if is_in_group("parried"):
		var effect := detonation.instantiate()
		effect.position = position
		get_parent().add_child(effect)
	else:
		var effect := bullet_death.instantiate()
		effect.position = position
		get_parent().add_child(effect)
	queue_free()

func _on_bullet_hurtbox_body_entered(body):
	if body.is_in_group("wall")  and hit_wall == false:
		die()

func _on_bullet_hurtbox_area_entered(area):
	if area.is_in_group("parry"):
		bullet_hitbox.add_to_group("parried")
		bullet_body.color = Color(0, 1, 1, 1)
		add_to_group("parried")
		bullet_hitbox.add_to_group("player_attack")
		speed += 1500.0
		shoot(global_position, get_global_mouse_position())
	if area.is_in_group("enemy") and is_in_group("parried"):
		var effect := detonation.instantiate()
		effect.position = position
		get_parent().call_deferred("add_child", effect)
		queue_free()

func die():
	if is_in_group("parried"):
		var effect := detonation.instantiate()
		effect.position = position
		get_parent().call_deferred("add_child", effect)
		hit_wall = true
		queue_free()
	else:
		var effect := bullet_death.instantiate()
		effect.position = position
		get_parent().call_deferred("add_child", effect)
		hit_wall = true
		queue_free()
