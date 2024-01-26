extends CharacterBody2D

var green_death := preload("res://enemies/green/green_death.tscn")
var green_hurt := preload("res://enemies/green/green_hurt.tscn")

var green_health = 3
var shoot_at_player = false

func _process(_delta):
	if green_health < 1:
		var effect := green_death.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		queue_free()
	if shoot_at_player and $GunTimer.is_stopped():
		$green_bulletsfx.play()
		var bullet_scene = preload("res://enemies/green/green_bullet.tscn")
		var shot = bullet_scene.instantiate()
		get_parent().add_child(shot)
		shot.shoot(global_position, get_node("../player").global_position)
		$GunTimer.start()

func _on_playerdeath_area_entered(area):
	if area.name == "bullet_hurtbox":
		var effect := green_hurt.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		green_health -= 1
	if area.is_in_group("beam"):
		var effect := green_hurt.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		green_health -= 2

func _on_player_detection_body_entered(body):
	if body.name == "player":
		shoot_at_player = true

func _on_player_detection_body_exited(body):
	if body.name == "player":
		shoot_at_player = false

func _on_gun_timer_timeout() -> void:
	$GunTimer.stop()
