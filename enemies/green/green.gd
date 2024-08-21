extends CharacterBody2D

var green_death := preload("res://enemies/green/green_death.tscn")
var green_hurt := preload("res://enemies/green/green_hurt.tscn")

var health = 3.0
@export var bullets_fired = 0
var guarded = false
var attack_player = true

func _ready():
	var effect := green_hurt.instantiate()
	effect.position = position
	get_parent().call_deferred("add_child", effect)

func _process(_delta):
	if health < 1:
		var effect := green_death.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		effect.die(1)
		queue_free()
	if $GunTimer.is_stopped() and bullets_fired <= 3 and $LaserTimer.is_stopped():
		bullets_fired += 1
		if attack_player:
			$green_bulletsfx.play()
			var bullet_scene = preload("res://enemies/green/green_bullet.tscn")
			var shot = bullet_scene.instantiate()
			get_parent().add_child(shot)
			shot.shoot(global_position, get_node("../player").global_position)
		#$GunTimer.wait_time = randf_range(0.75, 1)
		$GunTimer.start()
	if $LaserTimer.is_stopped() and bullets_fired > 3 and $GunTimer.is_stopped():
		bullets_fired = 0
		$green_lasersfx.play()
		eyes_begone()
		var bullet_scene = preload("res://enemies/green/green_laser.tscn")
		var shot = bullet_scene.instantiate()
		get_parent().add_child(shot)
		shot.shoot(global_position, get_node("../player").global_position)
		$LaserTimer.start()

func _physics_process(_delta):
	if $check_player_wall.enabled:
		$check_player_wall.look_at(get_node("../player").global_position)
	if $check_player_wall.is_colliding():
		if $check_player_wall.get_collider().is_in_group("wall"):
			attack_player = false
		else:
			attack_player = true

func _on_playerdeath_area_entered(area):
	if area.is_in_group("player_attack") and guarded == false:
		var effect := green_hurt.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		effect.die(0.5)
		health -= area.get_parent().damage

func eyes_begone():
	await get_tree().create_timer(1.2, false).timeout
	$body/eye_bottom.modulate = Color(0, 0, 0, 0)
	$body/eye_top.modulate = Color(0, 0, 0, 0)
	create_tween().tween_property($body/eye_bottom, "modulate", Color(1, 1, 1, 1), 1.8)
	create_tween().tween_property($body/eye_top, "modulate", Color(1, 1, 1, 1), 1.8)

func _on_update_raycast_area_entered(area):
	if area.is_in_group("player"):
		$check_player_wall.enabled = true
		attack_player = true

func _on_update_raycast_area_exited(area):
	if area.is_in_group("player"):
		$check_player_wall.enabled = false
		attack_player = false
