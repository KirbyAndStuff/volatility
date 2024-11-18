extends RayCast2D

var collision_polygon = CollisionPolygon2D.new()
var direction := Vector2.ZERO
var damage = 1
var rotation_speed = 1

func _ready():
	get_node("../camera").apply_shake(10, 0.75)
	$beam_hurtbox.add_child(collision_polygon)

func _physics_process(delta):
	if is_colliding():
		target_position = to_local(get_collision_point()) + Vector2(1000, 0)
		collision_polygon.polygon = [Vector2(0, 40), Vector2(target_position.x - 1000, 40), Vector2(target_position.x - 1000, -40), Vector2(0, -40)]
		$Line2D.points[1] = target_position - Vector2(1015, 0)
		$beam_end.position = target_position - Vector2(1025, 0)
		$beam_end.visible = true
	else:
		collision_polygon.polygon = [Vector2(0, 40), Vector2(2000, 40), Vector2(2000, -40), Vector2(0, -40)]
		$Line2D.points[1] = Vector2(2000, 0)
		$beam_end.visible = false
	position = get_node("../player").position
	var v = get_global_mouse_position() - global_position
	var angle = v.angle()
	var r = global_rotation
	var angle_delta = rotation_speed * delta
	angle = lerp_angle(r, angle, 1.0)
	angle = clamp(angle, r - angle_delta, r + angle_delta)
	global_rotation = angle

func shoot(from: Vector2, to: Vector2):
	global_position = from
	direction = from.direction_to(to)
	rotation = direction.angle()

func _on_beam_hurtbox_area_entered(area):
	if area.is_in_group("enemy_body"):
		if not area.is_in_group("no heal_cooldown reduction") and area.get_parent().guarded == false:
			get_node("../player").add_heal_cooldown(2.5)
		$beam_hurtbox.remove_from_group("player_attack")
		$beam_hurtbox.set_deferred("monitoring", false)
		await get_tree().create_timer(0.25, false).timeout
		$beam_hurtbox.add_to_group("player_attack")
		$beam_hurtbox.set_deferred("monitoring", true)

func _on_timer_timeout():
	create_tween().tween_property($Line2D, "width", 0, 0.25)
	create_tween().tween_property($beam_hurtbox, "scale", Vector2(1, 0), 0.25)
	$beam_end.speed_scale = 4
	$beam_end.emitting = false
	await get_tree().create_timer(0.25, false).timeout
	queue_free()
