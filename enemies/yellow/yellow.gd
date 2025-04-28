extends CharacterBody2D

var yellow_death := preload("res://enemies/yellow/yellow_death.tscn")
var yellow_hurt := preload("res://enemies/yellow/yellow_hurt.tscn")

var speed = 300
var health = 2.0
var max_health = 2.0
var shoot_at_player = false
var guarded = false

signal health_changed(new_health)
signal died

func _ready():
	$spawnsfx.global_position = get_node("../player").global_position
	$spawn.emitting = true
	await  $spawn.finished
	$spawn.queue_free()

func _physics_process(_delta):
	var direction = (get_node("../player").position-position).normalized()
	velocity=direction*speed
	move_and_slide()

func _process(_delta):
	if shoot_at_player and $GunTimer.is_stopped():
		$yellow_bulletsfx.play()
		var bullet_scene = preload("res://enemies/yellow/yellow_bullet.tscn")
		var shot = bullet_scene.instantiate()
		get_parent().add_child(shot)
		shot.shoot(global_position, get_node("../player").global_position)
		var effect := preload("res://enemies/yellow/yellow_bullet_explosion.tscn").instantiate()
		effect.position = position
		get_parent().add_child(effect)
		effect.shoot(global_position, get_node("../player").global_position)
		$GunTimer.start()

func _on_player_death_area_entered(area):
	if area.is_in_group("player_attack") and guarded == false:
		health -= area.get_parent().damage
		emit_signal("health_changed", health)
		if health > 0:
			var effect := yellow_hurt.instantiate()
			effect.position = position
			get_parent().add_child(effect)
		else:
			emit_signal("died")
			var effect := yellow_death.instantiate()
			effect.position = position
			get_parent().add_child(effect)
			queue_free()

func _on_player_shoot_distance_area_entered(area):
	if area.is_in_group("player"):
		shoot_at_player = true

func _on_player_shoot_distance_area_exited(area):
	if area.is_in_group("player"):
		shoot_at_player = false
