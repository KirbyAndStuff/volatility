extends Area2D

var directiona := Vector2.ZERO
var sfx := preload("res://player/attacks/melee_sfx.tscn")
var damage = 2

func _ready():
	var effect := sfx.instantiate()
	effect.position = get_node("../player").position
	get_parent().add_child(effect)
	$CPUParticles2D.emitting = true
	await get_tree().create_timer(0.3, false).timeout
	queue_free()

func _process(_delta):
	position = get_node("../player").position

func shoot(from: Vector2, to: Vector2):
	global_position = from
	directiona = from.direction_to(to)
	rotation = directiona.angle()

func _on_area_2d_area_entered(area):
	if area.is_in_group("enemy_body") and not area.is_in_group("no heal_cooldown reduction") and (get_node("../player").heal_cooldown) < 100 and area.get_parent().guarded == false:
		(get_node("../player").heal_cooldown) += 5
