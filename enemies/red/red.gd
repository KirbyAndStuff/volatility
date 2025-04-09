extends CharacterBody2D

var red_death := preload("res://enemies/red/red_death.tscn")
var red_dash_particles := preload("res://enemies/red/red_dash_particles.tscn")
var red_hurt := preload("res://enemies/red/red_hurt.tscn")

signal health_changed(new_health)
signal died

func _ready():
	$"left eye".lifetime = 0.1
	$"right eye".lifetime = 0.1
	$spawnsfx.global_position = get_node("../player").global_position
	$spawn.emitting = true
	await  $spawn.finished
	$spawn.queue_free()

var speed = 500
var dash_at_player = false
var health = 2.0
var max_health = 2.0
var guarded = false
var dont_move = 0
var dash_telegraph = false

@onready var red_dashlength = $Red_DashLength
@onready var eyes = [$"left eye", $"right eye"]

func _physics_process(delta):
	if dont_move < 1:
		position += (get_node("../player").position - position).normalized() * speed * delta
		if speed < 500:
			speed += 500 * delta
	move_and_slide()
	if not velocity == Vector2.ZERO:
		velocity = lerp(velocity, Vector2.ZERO, 0.01)
	if dash_telegraph:
		$dash_line.look_at(get_node("../player").global_position)
		$dash_line_particles.look_at(get_node("../player").global_position)

func _process(_delta):
	if dash_at_player and $Red_DashCooldown.is_stopped() and get_tree().get_nodes_in_group("red").size() < 3:
		$dash_line.modulate = Color(1, 1, 1, 1)
		create_tween().set_trans(Tween.TRANS_EXPO).tween_property($dash_line, "modulate", Color(1, 1, 1, 0), 0.5)
		$is_about_to_dashsfx.play()
		$Red_DashCooldown.start()
		dash_telegraph = true
		$dash_line_particles/CPUParticles2D.emitting = true
		$dash_line_particles/CPUParticles2D2.emitting = true
		$dash_line.look_at(get_node("../player").global_position)
		await get_tree().create_timer(0.5, false).timeout
		if not $hurts_player.is_in_group("parried"):
			$red_dashsfx.play()
			var effect := red_dash_particles.instantiate()
			effect.position = position
			get_parent().add_child(effect)
			speed *= 4
			dont_move += 1
			var direction = (get_node("../player").position-position).normalized()
			velocity=direction*speed
			dash_telegraph = false
			red_dashlength.start()

func _on_playerdeath_area_entered(area):
	if area.is_in_group("player_attack") and guarded == false:
		health -= area.get_parent().damage
		emit_signal("health_changed", health)
		if health > 0:
			var effect := red_hurt.instantiate()
			effect.position = position
			get_parent().add_child(effect)
		else:
			emit_signal("died")
			var effect := red_death.instantiate()
			effect.position = position
			get_parent().add_child(effect)
			queue_free()
	if area.is_in_group("parry") and guarded == false:
		$hurts_player.add_to_group("parried")
		$hurts_player/CollisionShape2D.set_deferred("disabled", true)
		$player_dash_distance/CollisionShape2D.set_deferred("disabled", true)
		dont_move += 1
		dash_telegraph = false
		velocity = Vector2.ZERO
		speed = 0
		dash_at_player = false
		$stunned_eye1.emitting = true
		$stunned_eye2.emitting = true
		for vol in eyes:
			vol.emitting = false
		$Stunned.start()

func _on_red_dash_length_timeout() -> void:
	if not $hurts_player.is_in_group("parried"):
		speed /= 4
	dont_move -= 1

func _on_timer_timeout():
	$hurts_player.remove_from_group("parried")
	for vol in eyes:
		vol.lifetime = 0.2
		vol.speed_scale = 0.3
		vol.emitting = true
		create_tween().tween_property(vol, "lifetime", 0.1, 1.5)
	$stunned_eye2.emitting = false
	await get_tree().create_timer(1, false).timeout
	dont_move -= 1
	$hurts_player.remove_from_group("parried")
	$hurts_player/CollisionShape2D.set_deferred("disabled", false)
	$player_dash_distance/CollisionShape2D.set_deferred("disabled", false)
	await get_tree().create_timer(1, false).timeout
	if not $hurts_player.is_in_group("parried"):
		speed = 500
		$"left eye".speed_scale = 0.5
		$"right eye".speed_scale = 0.5

func _on_player_dash_distance_area_entered(area):
	if area.is_in_group("player") and not $hurts_player.is_in_group("parried"):
		dash_at_player = true

func _on_player_dash_distance_area_exited(area):
	if area.is_in_group("player"):
		dash_at_player = false
