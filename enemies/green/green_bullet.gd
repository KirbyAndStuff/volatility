extends CharacterBody2D

var direction := Vector2.ZERO
var green_bullet_death := preload("res://enemies/green/green_bullet_death.tscn")
var detonation := preload("res://player/attacks/beam_detonation.tscn")
var hit_wall = false
var enemies_hit = 0

@export var speed := 1000.0
var attack_player = false

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
		var effect := green_bullet_death.instantiate()
		effect.position = position
		get_parent().add_child(effect)
	queue_free()

func _process(_delta):
	if attack_player and (get_node("../player").attackable) == true:
		(get_node("../player").health) -= 1
		(get_node("../player").i_frames(1))
		(get_node("../player").player_hurt_particles())
		(get_node("../player").framefreeze(0.4, 0.3))
	if 1 < enemies_hit:
		var effect := detonation.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		queue_free()

func _on_green_bullet_hurtbox_body_entered(body):
	if body.name == "player":
		attack_player = true
	if body.is_in_group("wall")  and hit_wall == false:
		if is_in_group("parried"):
			var effect := detonation.instantiate()
			effect.position = position
			get_parent().call_deferred("add_child", effect)
			hit_wall = true
			queue_free()
		else:
			var effect := green_bullet_death.instantiate()
			effect.position = position
			get_parent().add_child(effect)
			hit_wall = true
			queue_free()

func _on_green_bullet_hurtbox_body_exited(body):
	if body.name == "player":
		attack_player = false

func _on_green_bullet_hurtbox_area_entered(area):
	if area.is_in_group("beam"):
		var effect := detonation.instantiate()
		effect.position = position
		get_parent().call_deferred("add_child", effect)
		queue_free()
	if area.is_in_group("parry"):
		$bullet_body.color = Color(0, 1, 1, 1)
		add_to_group("parried")
		$green_bullet_hurtbox.add_to_group("deal 2 damage")
		speed = 2500.0
		shoot(global_position, get_global_mouse_position())
	if area.is_in_group("enemy") and is_in_group("parried"):
		enemies_hit += 1
