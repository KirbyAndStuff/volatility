extends CharacterBody2D

var particlesL: CPUParticles2D
var particlesR: CPUParticles2D
var plred_death := preload("res://enemies/red_death.tscn")

func _ready():
	particlesL = $"left eye"
	particlesR = $"right eye"

var speed = 300
var player_chase = false
var player = null

func _physics_process(delta):
	if player_chase:
		var direction = (player.position-position).normalized()
		velocity=direction*speed
		move_and_slide()
		

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
		body.health -= 1
