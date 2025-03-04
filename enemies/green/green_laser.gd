extends RayCast2D

var collision_polygon = CollisionPolygon2D.new()
var direction := Vector2.ZERO
var predicting = true
var enemies_in = 0
var sfx := preload("res://enemies/green/green_lasersfx.tscn")

func _ready():
	await get_tree().create_timer(0.1, false).timeout
	create_tween().set_trans(Tween.TRANS_EXPO).tween_property(self, "modulate", Color(1, 1, 1, 1), 0.3)
	visible = true

func _physics_process(_delta):
	if predicting:
		#var dist = global_position.distance_to(get_node("../player").global_position)
		look_at(Vector2(get_node("../player").global_position.x + clamp(get_node("../player").velocity.x, -700, 700) / 3, get_node("../player").global_position.y + clamp(get_node("../player").velocity.y, -700, 700) / 3))

func shoot(from: Vector2, to: Vector2):
	global_position = from
	direction = from.direction_to(to)
	rotation = direction.angle()

func _on_timer_die_timeout() -> void:
	diea()

func diea():
	create_tween().tween_property($attack, "width", 0, 0.25)
	create_tween().tween_property($hurtbox, "scale", Vector2(1, 0), 0.25)
	await get_tree().create_timer(0.25, false).timeout
	queue_free()

func _on_timer_attack_timeout():
	$AudioStreamPlayer2D.play()
	await get_tree().create_timer(0.1, false).timeout
	$line.width = 3
	$line.default_color = Color(0, 1, 0, 1)
	predicting = false
	await get_tree().create_timer(0.3, false).timeout
	var effect := sfx.instantiate()
	effect.position = position
	get_parent().add_child(effect)
	$line.visible = false
	$attack.visible = true
	$hurtbox.add_child(collision_polygon)
	collision_polygon.polygon = [Vector2(0, 10), Vector2(5000, 10), Vector2(5000, -10), Vector2(0, -10)]
	if get_node("../camera").shake_strength < 0.1:
		get_node("../camera").apply_shake(5, 0.4)
	$TimerDie.start()

func _on_check_area_entered(area):
	if area.is_in_group("green_laser"):
		enemies_in += 1

func _on_check_area_exited(area):
	if area.is_in_group("green_laser"):
		enemies_in -= 1
		if enemies_in == 0:
			queue_free()
