extends CharacterBody2D

var direction := Vector2.ZERO
var bullet_death := preload("res://player/attacks/alt_bullet/alt_bullet_death.tscn")
var detonation := preload("res://player/attacks/bullet/beam_detonation.tscn")
var charged_blades := preload("res://player/attacks/alt_bullet/alt_bullet_charged.tscn")
var speed = 2500.0
var drain_speed = true
var come_back = false
var hit_wall = false
var enemies_hit = 0
var damage = 1
var in_beam = false
var beam_progress = 0.0
var charged = false
var closest_enemy = null
@onready var blades = [$blade, $blade2, $blade3, $blade4]

func _ready():
	create_tween().tween_property(self, "scale", Vector2(1, 1), 0.2)

func _process(_delta):
	if 2 < enemies_hit:
		die()
	if beam_progress >= 50 and charged == false:
		for vol in blades:
			vol.emitting = true
			vol.modulate = Color(1, 3, 3, 1)
		charged = true
		$chargedsfx.play()
	for vol in blades:
		vol.color = Color(beam_progress / 70, beam_progress / 70, beam_progress / 70, beam_progress / 70)

func shoot(from: Vector2, to: Vector2):
	global_position = from
	direction = from.direction_to(to)
	rotation = direction.angle()

func _physics_process(delta):
	position += direction * speed * delta
	if drain_speed:
		speed -= 5000.0 * delta
	else:
		speed += 5000.0 * delta
	if speed < 0 and drain_speed:
		drain_speed = false
		come_back = true
		$player_death/CollisionShape2D.disabled = false
		$hurtbox.add_to_group("parryable")
	if come_back:
		direction = global_position.direction_to(get_node("../player").position)
	if in_beam:
		if come_back:
			speed -= 3000.0 * delta
		else:
			speed += 3000.0 * delta
		if beam_progress < 70:
			beam_progress += 100 * delta
	$stop_follow_player.scale = Vector2(speed, speed) / 2500.0

func _on_hurtbox_area_entered(area):
	if area.is_in_group("enemy_body"):
		if not area.is_in_group("no heal_cooldown reduction") and (get_node("../player").heal_cooldown) < 100 and area.get_parent().guarded == false:
			(get_node("../player").heal_cooldown) = clamp((get_node("../player").heal_cooldown) + 5, 0, 100)
		enemies_hit += 1
	if area.is_in_group("beam") and not is_in_group("parried"):
		in_beam = true
	if area.is_in_group("parry") and not is_in_group("parried"):
		come_back = false
		$Timer.start()
		$player_death.monitoring = false
		$body.color = Color(0, 1, 1, 1)
		$flames.color = Color(0, 1, 1, 1)
		add_to_group("parried")
		speed += 2500.0
		shoot(global_position, get_global_mouse_position())
	if area.is_in_group("enemy") and is_in_group("parried"):
		die()

func _on_player_death_area_entered(area):
	if area.is_in_group("player") and get_node("../player").amount_of_i_frames < 1:
		die()

func _on_hurtbox_body_entered(body):
	if body.is_in_group("wall") and hit_wall == false:
		hit_wall = true
		die()

func die():
	if is_in_group("parried"):
		var effect := detonation.instantiate()
		effect.position = position
		get_parent().call_deferred("add_child", effect)
		queue_free()
	if charged:
		var effecta := charged_blades.instantiate()
		effecta.position = position
		get_parent().call_deferred("add_child", effecta)
		queue_free()
	if not is_in_group("parried") and charged == false:
		var effect := bullet_death.instantiate()
		effect.position = $body.global_position
		get_parent().add_child(effect)
		effect.die(0.5)
		queue_free()

func _on_timer_timeout():
	die()

func _on_hurtbox_area_exited(area):
	if area.is_in_group("beam"):
		in_beam = false

func _on_stop_follow_player_area_entered(area):
	if area.is_in_group("player"):
		come_back = false

func _on_stop_follow_player_area_exited(area):
	if area.is_in_group("player") and not is_in_group("parried") and scale == Vector2(1, 1):
		come_back = false
		drain_speed = true
		if speed > 1500.0:
			speed = 1500.0
		enemies_hit = 0
		await get_tree().create_timer(0.001, false).timeout
		if get_tree().has_group("enemy_body"):
			var closest_distance = INF
			for enemy in get_tree().get_nodes_in_group("enemy_body"):
				if global_position.distance_to(enemy.global_position) < closest_distance:
					closest_distance = global_position.distance_to(enemy.global_position)
					closest_enemy = enemy
			var bullet_scene = preload("res://player/attacks/alt_bullet/alt_bullet_dodge.tscn")
			var shot = bullet_scene.instantiate() 
			get_parent().call_deferred("add_child", shot)
			shot.shoot(global_position, closest_enemy.global_position)
