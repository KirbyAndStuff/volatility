extends RayCast2D

var boom := preload("res://player/attacks/bullet/bulletm2_boom.tscn")

var direction := Vector2.ZERO
var damage = 3
var shake = 20
var shot = false
var sfx = 5
var remove_from_groupa = false

func _ready():
	get_node("../camera").apply_shake(shake, 0.25)
	create_tween().tween_property($Line2D, "width", 0, 0.5)
	await get_tree().create_timer(0.1, false).timeout
	shot = true

func _physics_process(_delta):
	if is_colliding() and shot == false:
		target_position = to_local(get_collision_point()) + Vector2(1000, 0)
		$Line2D.points[1] = target_position - Vector2(1000, 0)
		$end.position = target_position - Vector2(1000, 0)
		var effect := boom.instantiate()
		effect.directiona = direction
		effect.global_position = $end.global_position
		if get_collider().is_in_group("bullet"):
			effect.lifetime = 0.75
			effect.hurtbox_size = Vector2(1.4, 1.4)
			effect.speed_scale = 1.5
			effect.scale = Vector2(1.5, 1.5)
			effect.sfx_big = true
			damage = 6
			get_collider().queue_free()
		if get_collider().is_in_group("big_bullet"):
			effect.lifetime = 1
			effect.hurtbox_size = Vector2(1.8, 1.8)
			effect.speed_scale = 2
			effect.scale = Vector2(2, 2)
			effect.sfx_big = true
			effect.sfx_big_db = -2
			effect.sfx_big_ps = 0.5
			damage = 10
			get_collider().queue_free()
		effect.damage = damage
		effect.sfx_db = sfx
		effect.remove_from_groupa = remove_from_groupa
		get_parent().add_child(effect)
		shot = true
	elif shot == false:
		$Line2D.points[1] = Vector2(2000, 0)
		$end.position = Vector2(2000, 0)
		var effect := boom.instantiate()
		effect.global_position = $end.global_position
		effect.sfx_db = sfx
		get_parent().add_child(effect)
		shot = true

func shoot(from: Vector2, to: Vector2):
	global_position = from
	direction = from.direction_to(to)
	rotation = direction.angle()

func _on_die_timer_timeout():
	queue_free()
