extends RayCast2D

var collision_polygon = CollisionPolygon2D.new()
var shot = false
var damage = 1.5
var width = 30

func _ready():
	$hurtbox.add_child(collision_polygon)
	await get_tree().create_timer(0.1, false).timeout
	create_tween().tween_property($Line2D, "width", 0, 0.5)
	shot = true

func _physics_process(_delta: float) -> void:
	if is_colliding() and shot == false:
		target_position = to_local(get_collision_point()) + Vector2(1000, 0)
		collision_polygon.polygon = [Vector2(0, width), Vector2(target_position.x - 1000, width), Vector2(target_position.x - 1000, -width), Vector2(0, -width)]
		$Line2D.points[1] = target_position - Vector2(1000, 0)
	elif shot == false:
		collision_polygon.polygon = [Vector2(0, width), Vector2(2000, width), Vector2(2000, -width), Vector2(0, -width)]
		$Line2D.points[1] = Vector2(2000, 0)
		shot = true

func _on_timer_timeout() -> void:
	queue_free()

func _on_hurtbox_area_entered(area):
	if area.is_in_group("enemy_body"):
		if not area.is_in_group("no heal_cooldown reduction") and area.get_parent().guarded == false:
			get_node("../player").add_heal_cooldown(2.5)
