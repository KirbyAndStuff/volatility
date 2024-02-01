extends CharacterBody2D

var yellow_death := preload("res://enemies/yellow/yellow_death.tscn")
var yellow_hurt := preload("res://enemies/yellow/yellow_hurt.tscn")

var speed = 150
var player_chase = false
var player = null
var yellow_health = 2
var shoot_at_player = false

func _ready():
	var effect := yellow_hurt.instantiate()
	effect.position = position
	get_parent().add_child(effect)

func _physics_process(_delta):
	if player_chase:
		var direction = (player.position-position).normalized()
		velocity=direction*speed
		move_and_slide()

func _process(_delta):
	if yellow_health < 1:
		var effect := yellow_death.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		queue_free()
	if shoot_at_player and $GunTimer.is_stopped():
		$yellow_bulletsfx.play()
		var bullet_scene = preload("res://enemies/yellow/yellow_bullet.tscn")
		var shot = bullet_scene.instantiate()
		get_parent().add_child(shot)
		shot.shoot(global_position, get_node("../player").global_position)
		$GunTimer.start()

func _on_player_death_area_entered(area):
	if area.name == "bullet_hurtbox":
		var effect := yellow_hurt.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		yellow_health -= 1
	if area.is_in_group("beam"):
		var effect := yellow_hurt.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		yellow_health -= 2

func _on_gun_timer_timeout():
	$GunTimer.stop()

func _on_player_detection_area_entered(area):
	if area.is_in_group("player"):
		player = area.get_parent()
		player_chase = true

func _on_player_detection_area_exited(area):
	if area.is_in_group("player"):
		player = null
		player_chase = false

func _on_player_shoot_distance_area_entered(area):
	if area.is_in_group("player"):
		shoot_at_player = true

func _on_player_shoot_distance_area_exited(area):
	if area.is_in_group("player"):
		shoot_at_player = false
