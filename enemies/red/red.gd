extends CharacterBody2D

var red_death := preload("res://enemies/red/red_death.tscn")
var red_dash_particles := preload("res://enemies/red/red_dash_particles.tscn")
var red_hurt := preload("res://enemies/red/red_hurt.tscn")

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

@onready var red_dashlength = $Red_DashLength
@onready var eyes = [$"left eye", $"right eye"]
@onready var stunned_eyes = [$stunned_eye, $stunned_eye2, $stunned_eye3, $stunned_eye4]

func _physics_process(delta):
	if speed <= 500:
		position += (get_node("../player").position - position).normalized() * speed * delta
	move_and_slide()
	if not velocity == Vector2.ZERO:
		velocity = lerp(velocity, Vector2.ZERO, 0.01)

func _process(_delta):
	if dash_at_player and $Red_DashCooldown.is_stopped():
		$is_about_to_dashsfx.play()
		$Red_DashCooldown.start()
		var effect := red_dash_particles.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		await get_tree().create_timer(0.5, false).timeout
		if not $hurts_player.is_in_group("parried"):
			$red_dashsfx.play()
			speed *= 4
			var direction = (get_node("../player").position-position).normalized()
			velocity=direction*speed
			red_dashlength.start()
	if health <= 0:
		var effect := red_death.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		queue_free()

func _on_playerdeath_area_entered(area):
	if area.is_in_group("player_attack") and guarded == false:
		if health > 1:
			var effect := red_hurt.instantiate()
			effect.position = position
			get_parent().add_child(effect)
		health -= area.get_parent().damage
	if area.is_in_group("parry") and guarded == false:
		$hurts_player.add_to_group("parried")
		velocity = Vector2.ZERO
		speed = 0
		dash_at_player = false
		for vol in eyes:
			vol.emitting = false
		for vol in stunned_eyes:
			vol.emitting = true
		$Stunned.start()

func _on_red_dash_length_timeout() -> void:
	speed /= 4

func _on_timer_timeout():
	$hurts_player.remove_from_group("parried")
	for vol in eyes:
		vol.emitting = true
	for vol in stunned_eyes:
		vol.emitting = false
	speed = 500

func _on_player_dash_distance_area_entered(area):
	if area.is_in_group("player") and not $hurts_player.is_in_group("parried"):
		dash_at_player = true

func _on_player_dash_distance_area_exited(area):
	if area.is_in_group("player"):
		dash_at_player = false
