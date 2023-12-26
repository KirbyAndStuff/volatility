extends CharacterBody2D

var speed = 150
var player_chase = false
var player = null
var yellow_health = 2
var shoot_at_player = false

func _physics_process(delta):
	if player_chase:
		var direction = (player.position-position).normalized()
		velocity=direction*speed
		move_and_slide()

func _process(delta):
	if yellow_health < 1:
		queue_free()
	if shoot_at_player and $GunTimer.is_stopped():
		var bullet_scene = preload("res://enemies/yellow/yellow_bullet.tscn")
		var shot = bullet_scene.instantiate()
		get_parent().add_child(shot)
		shot.shoot(global_position, get_node("../player").global_position)
		$GunTimer.start()

func _on_player_death_area_entered(area):
	if area.name == "bullet_hurtbox":
		yellow_health -= 1
	if area.name == "parried_hurtbox":
		yellow_health -= 2

func _on_player_detection_body_entered(body):
	player = body
	player_chase = true

func _on_player_detection_body_exited(body):
	player = null
	player_chase = false

func _on_player_shoot_distance_body_entered(body):
	if body.name == "player":
		shoot_at_player = true

func _on_player_shoot_distance_body_exited(body):
	if body.name == "player":
		shoot_at_player = false

func _on_gun_timer_timeout():
	$GunTimer.stop()
