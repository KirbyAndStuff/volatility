extends RayCast2D

var beama = true
var collision_shape = CollisionShape2D.new()
var segment_shape = SegmentShape2D.new()
var direction := Vector2.ZERO
var damage = 2

func _ready():
	$beam_hurtbox.add_child(collision_shape)

func _physics_process(_delta):
	if is_colliding():
		target_position = to_local(get_collision_point())
	$beam_body.position = target_position * 0.5
	$beam_body.process_material.emission_box_extents.x = target_position.length() * 0.5 + -15
	if beama:
		$beam_body.emitting = true
	segment_shape.a = Vector2(0, 0)
	segment_shape.b = target_position
	collision_shape.shape = segment_shape

func shoot(from: Vector2, to: Vector2):
	global_position = from
	direction = from.direction_to(to)
	rotation = direction.angle()

func _on_timer_timeout() -> void:
	beama = false
	$beam_body.emitting = false
	await get_tree().create_timer(0.25, false).timeout
	queue_free()

func _on_beam_hurtbox_area_entered(area):
	if area.is_in_group("enemy_body") and not area.is_in_group("no heal_cooldown reduction") and (get_node("../player").heal_cooldown) < 100:
		(get_node("../player").heal_cooldown) += 5
