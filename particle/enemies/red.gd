extends CharacterBody2D

var particlesL: CPUParticles2D
var particlesR: CPUParticles2D
var plred_death := preload("res://enemies/red_death.tscn")
var red_dash_particles := preload("res://enemies/red_dash_particles.tscn")

func _ready():
	particlesL = $"left eye"
	particlesR = $"right eye"
	add_to_group("enemy")

var speed = 300
var player_chase = false
var player = null
var attack_player = false
var dash_at_player = false
var red_stamina = 20

@onready var red_dashlength = $Red_DashLength

func _physics_process(delta):
	if player_chase:
		var direction = (player.position-position).normalized()
		velocity=direction*speed
		move_and_slide()

func _process(delta):
	if attack_player and (get_node("../player").i_frames) == false and (get_node("../player").dashi_frames) == false:
		(get_node("../player").health) -= 1
		(get_node("../player").i_frames) = true
	if red_stamina <= 20:
		red_stamina += 10 * delta
	if dash_at_player == true:
		speed = 1500

func _on_playerdeath_body_entered(body):
	if body.name == "bullet4":
		var effect := plred_death.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		
		queue_free()


func _on_player_detection_body_entered(body):
	player = body
	player_chase = true
	particlesL.lifetime = 0.1
	particlesR.lifetime = 0.1


func _on_player_detection_body_exited(body):
	player = null
	player_chase = false
	particlesL.lifetime = 0.2
	particlesR.lifetime = 0.2


func _on_hurts_player_body_entered(body):
	if body.name == "player":
		attack_player = true

func _on_hurts_player_body_exited(body):
	if body.name == "player":
		attack_player = false
		

func _on_player_dash_distance_body_entered(body):
	if body.name == "player" and red_stamina > 19:
		red_stamina -= 20
		var effect := red_dash_particles.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		await get_tree().create_timer(0.5).timeout
		dash_at_player = true
		red_dashlength.start()
		
func _on_player_dash_distance_body_exited(body):
	if body.name == "player" and red_stamina > 19:
		red_stamina -= 20
		var effect := red_dash_particles.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		await get_tree().create_timer(0.5).timeout
		dash_at_player = true
		red_dashlength.start()
		

func _on_red_dash_length_timeout() -> void:
	speed = 300
	dash_at_player = false
