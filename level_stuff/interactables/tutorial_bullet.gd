extends CharacterBody2D

var direction := Vector2.ZERO
var bullet_death := preload("res://player/attacks/bullet_death.tscn")
var detonation := preload("res://player/attacks/beam_detonation.tscn")
var hit_wall = false

@export var speed := 1000.0

func _ready():
	$explosion_top.emitting = true
	$explosion_bottom.emitting = true

func _physics_process(delta):
	position += direction * speed * delta

func shoot(from: Vector2, to: Vector2):
	global_position = from
	direction = from.direction_to(to)
	rotation = direction.angle()

func _on_bullet_hurtbox_body_entered(body):
	if body.is_in_group("wall") and hit_wall == false:
		if is_in_group("parried"):
			var effect := detonation.instantiate()
			effect.position = $bullet_body.global_position
			get_parent().call_deferred("add_child", effect)
			hit_wall = true
			queue_free()
		else:
			var effect := bullet_death.instantiate()
			effect.scale = Vector2(5, 5)
			effect.position = $bullet_body.global_position
			get_parent().add_child(effect)
			hit_wall = true
			queue_free()

func _on_bullet_hurtbox_area_entered(area) -> void:
	if area.is_in_group("parry"):
		$bullet_body.color = Color(0, 1, 1, 1)
		add_to_group("parried")
		speed = 2500.0
		shoot(global_position, get_global_mouse_position())

func _on_timer_timeout():
	queue_free()

func _on_parry_hurtbox_area_entered(area) -> void:
	if area.is_in_group("player"):
		$parry_hurtbox.add_to_group("enemy_attack")

func _on_parry_hurtbox_area_exited(area) -> void:
	if area.is_in_group("player"):
		$parry_hurtbox.remove_from_group("enemy_attack")
