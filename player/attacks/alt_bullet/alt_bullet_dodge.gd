extends RayCast2D

var collision_polygon = CollisionPolygon2D.new()
var direction := Vector2.ZERO
var damage = 1
var rotation_speed = 1
var closest_enemy = null
var sfx := preload("res://player/attacks/alt_bullet/alt_bullet_dodge_sfx.tscn")

func _ready():
	$beam_hurtbox.add_child(collision_polygon)
	var effect := sfx.instantiate()
	effect.position = position
	get_parent().add_child(effect)
	effect.die(1.25)

func _physics_process(delta):
	if is_colliding():
		target_position = to_local(get_collision_point()) + Vector2(1000, 0)
		collision_polygon.polygon = [Vector2(0, 25), Vector2(target_position.x - 1000, 25), Vector2(target_position.x - 1000, -25), Vector2(0, -25)]
		$Line2D.points[1] = target_position - Vector2(1000, 0)
	else:
		collision_polygon.polygon = [Vector2(0, 25), Vector2(2000, 25), Vector2(2000, -25), Vector2(0, -25)]
		$Line2D.points[1] = Vector2(2000, 0)
	if get_tree().has_group("alt_bullet"):
		global_position = get_tree().get_first_node_in_group("alt_bullet").global_position
	else:
		diea()
	var closest_distance = INF
	for enemy in get_tree().get_nodes_in_group("enemy_body"):
		if global_position.distance_to(enemy.global_position) < closest_distance:
			closest_distance = global_position.distance_to(enemy.global_position)
			closest_enemy = enemy
	if get_tree().has_group("enemy_body"):
		var v = closest_enemy.global_position - global_position
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

func _on_timer_timeout() -> void:
	diea()

func _on_beam_hurtbox_area_entered(area):
	if area.is_in_group("enemy_body"):
		if not area.is_in_group("no heal_cooldown reduction") and (get_node("../player").heal_cooldown) < 100 and area.get_parent().guarded == false:
			(get_node("../player").heal_cooldown) = clamp((get_node("../player").heal_cooldown) + 2.5, 0, 100)

func diea():
	create_tween().tween_property($Line2D, "width", 0, 0.25)
	create_tween().tween_property($beam_hurtbox, "scale", Vector2(1, 0), 0.1)
	await get_tree().create_timer(0.1, false).timeout
	queue_free()
