extends CharacterBody2D

var direction := Vector2.ZERO
var bullet_death := preload("res://player/attacks/bullet/bullet_death.tscn")
var detonation := preload("res://player/attacks/bullet/beam_detonation.tscn")
var hit_wall = false
var enemies_hit = 0
var damage = 1

@export var speed := 2500.0

func _process(_delta):
	if 1 < enemies_hit:
		die()

func shoot(from: Vector2, to: Vector2):
	global_position = from
	direction = from.direction_to(to)
	rotation = direction.angle()

func _physics_process(delta):
	position += direction * speed * delta

func _on_timer_timeout() -> void:
	$bullet_body.emitting = false
	await get_tree().create_timer(0.3, false).timeout
	var effect := bullet_death.instantiate()
	effect.position = position
	get_parent().add_child(effect)
	queue_free()

func _on_bullet_hurtbox_body_entered(body):
	if body.is_in_group("wall") and hit_wall == false:
		hit_wall = true
		die()

func _on_bullet_hurtbox_area_entered(area):
	if area.is_in_group("enemy_body"):
		if not area.is_in_group("no heal_cooldown reduction") and area.get_parent().guarded == false:
			get_node("../player").add_heal_cooldown(5)
		enemies_hit += 1
	if area.is_in_group("beam"):
		var effect := detonation.instantiate()
		effect.position = position
		get_parent().call_deferred("add_child", effect)
		queue_free()

func die():
	var effect := bullet_death.instantiate()
	effect.position = $bullet_body.global_position
	get_parent().add_child(effect)
	queue_free()
