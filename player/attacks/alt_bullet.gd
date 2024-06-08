extends CharacterBody2D

var direction := Vector2.ZERO
var bullet_death := preload("res://player/attacks/alt_bullet_death.tscn")
var detonation := preload("res://player/attacks/beam_detonation.tscn")
var charged_blades := preload("res://player/attacks/alt_bullet_charged.tscn")
var speed = 2500.0
var drain_speed = true
var come_back = false
var hit_wall = false
var enemies_hit = 0
var damage = 1
var in_beam = false
var beam_progress = 0.0
var charged = false
@onready var blades = [$blade, $blade2, $blade3, $blade4]

func _ready():
	create_tween().tween_property(self, "scale", Vector2(1, 1), 0.2)

func _process(_delta):
	if 2 < enemies_hit:
		die()
	if beam_progress >= 70 and charged == false:
		for vol in blades:
			vol.emitting = true
			vol.modulate = Color(1, 3, 3, 1)
		charged = true
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
		shoot(position, get_node("../player").position)
		in_beam = false
	if in_beam:
		speed += 3000.0 * delta
		beam_progress += 100 * delta

func _on_hurtbox_area_entered(area):
	if area.is_in_group("enemy_body"):
		if not area.is_in_group("no heal_cooldown reduction") and (get_node("../player").heal_cooldown) < 100 and area.get_parent().guarded == false:
			(get_node("../player").heal_cooldown) = clamp((get_node("../player").heal_cooldown) + 5, 0, 100)
		enemies_hit += 1
	if area.is_in_group("beam") and not is_in_group("parried"):
		in_beam = true
	if area.is_in_group("parry"):
		come_back = false
		$Timer.start()
		damage = 0
		$player_death.queue_free()
		$body.color = Color(0, 1, 1, 1)
		$flames.color = Color(0, 1, 1, 1)
		add_to_group("parried")
		speed += 2500.0
		shoot(global_position, get_global_mouse_position())
	if area.is_in_group("enemy") and is_in_group("parried"):
		die()

func _on_player_death_area_entered(area):
	if area.is_in_group("player"):
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
		queue_free()

func _on_timer_timeout():
	die()

func _on_hurtbox_area_exited(area):
	if area.is_in_group("beam"):
		in_beam = false
		if charged == false:
			beam_progress = 0
