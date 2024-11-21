extends CharacterBody2D

var direction := Vector2.ZERO
var attack_area : = preload("res://enemies/yellow/yellow_attack_area.tscn")
var detonation := preload("res://player/attacks/bullet/beam_detonation.tscn")
var hit_wall = false
var damage = 2

@export var speed := 750.0

func shoot(from: Vector2, to: Vector2):
	global_position = from
	direction = from.direction_to(to)
	rotation = direction.angle()

func _physics_process(delta):
	position += direction * speed * delta

func _on_timer_timeout() -> void:
	$bullet_body.emitting = false
	await get_tree().create_timer(0.27, false).timeout
	if is_in_group("parried"):
		var effect := detonation.instantiate()
		effect.position = position
		get_parent().add_child(effect)
	else:
		var effect := attack_area.instantiate()
		effect.position = position
		get_parent().add_child(effect)
	queue_free()

func _on_yellow_bullet_hurtbox_body_entered(body):
	if body.is_in_group("wall") and hit_wall == false:
		if is_in_group("parried"):
			var effect := detonation.instantiate()
			effect.position = position
			get_parent().call_deferred("add_child", effect)
			hit_wall = true
			queue_free()
		else:
			var effect := attack_area.instantiate()
			effect.position = position
			get_parent().call_deferred("add_child", effect)
			hit_wall = true
			queue_free()

func _on_yellow_bullet_hurtbox_area_entered(area):
	if area.is_in_group("beam"):
		var effect := detonation.instantiate()
		effect.position = position
		get_parent().call_deferred("add_child", effect)
		queue_free()
	if area.is_in_group("parry"):
		$yellow_bullet_hurtbox.add_to_group("parried")
		$bullet_body.color = Color(0, 1, 1, 1)
		add_to_group("parried")
		$yellow_bullet_hurtbox.add_to_group("player_attack")
		speed = 2500.0
		shoot(global_position, get_global_mouse_position())
	if area.is_in_group("enemy") and is_in_group("parried"):
		var effect := detonation.instantiate()
		effect.position = position
		get_parent().call_deferred("add_child", effect)
		queue_free()
