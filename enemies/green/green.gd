extends CharacterBody2D

var green_death := preload("res://enemies/green/green_death.tscn")
var green_hurt := preload("res://enemies/green/green_hurt.tscn")

var health = 3.0
var max_health = 3.0
@export var bullets_fired = 0
@export var can_fire_laser = true
var guarded = false
var attack_player = false
var behind_wall = false

signal health_changed(new_health)
signal died

func _ready():
	$spawnsfx.global_position = get_node("../player").global_position
	$spawn.emitting = true
	await  $spawn.finished
	$spawn.queue_free()

func _process(_delta):
	if $GunTimer.is_stopped() and bullets_fired <= 7 and $LaserTimer.is_stopped():
		if attack_player:
			if can_fire_laser:
				bullets_fired += 1
			$green_bulletsfx.play()
			var bullet_scene = preload("res://enemies/green/green_bullet.tscn")
			var shot = bullet_scene.instantiate()
			get_parent().add_child(shot)
			shot.shoot(global_position, get_node("../player").global_position)
			var effect := preload("res://enemies/green/green_bullet_explosion.tscn").instantiate()
			effect.position = position
			get_parent().add_child(effect)
			effect.shoot(global_position, get_node("../player").global_position)
			$GunTimer.start()
		elif can_fire_laser and behind_wall:
			bullets_fired += 2
			$GunTimer.start()
	if $LaserTimer.is_stopped() and bullets_fired > 7 and $GunTimer.is_stopped():
		bullets_fired = 0
		eyes_begone()
		var bullet_scene = preload("res://enemies/green/green_laser.tscn")
		var shot = bullet_scene.instantiate()
		get_parent().add_child(shot)
		shot.shoot(global_position, get_node("../player").global_position)
		$LaserTimer.start()
		await get_tree().create_timer(0.1, false).timeout
		$green_lasersfx.play()

func _physics_process(_delta):
	$check_player_wall.look_at(get_node("../player").global_position)
	if $check_player_wall.is_colliding():
		if is_instance_valid($check_player_wall.get_collider()):
			if $check_player_wall.get_collider().is_in_group("wall"):
				attack_player = false
				behind_wall = true
				$playerdeath/CollisionShape2D.disabled = true
			else:
				attack_player = true
				behind_wall = false
				$playerdeath/CollisionShape2D.disabled = false

func _on_playerdeath_area_entered(area):
	if area.is_in_group("player_attack") and guarded == false:
		health -= area.get_parent().damage
		emit_signal("health_changed", health)
		if health > 0:
			var effect := green_hurt.instantiate()
			effect.position = position
			get_parent().add_child(effect)
		else:
			emit_signal("died")
			var effect := green_death.instantiate()
			effect.position = position
			get_parent().add_child(effect)
			queue_free()

func eyes_begone():
	await get_tree().create_timer(1.4, false).timeout
	$body/eye_bottom.modulate = Color(0, 0, 0, 0)
	$body/eye_top.modulate = Color(0, 0, 0, 0)
	$body/eye_bottom.speed_scale = 0
	$body/eye_top.speed_scale = 0
	create_tween().tween_property($body/eye_bottom, "modulate", Color(1, 1, 1, 1), 1.8)
	create_tween().tween_property($body/eye_top, "modulate", Color(1, 1, 1, 1), 1.8)
	create_tween().set_trans(Tween.TRANS_QUAD).tween_property($body/eye_bottom, "speed_scale", 1, 1.8)
	create_tween().set_trans(Tween.TRANS_QUAD).tween_property($body/eye_top, "speed_scale", 1, 1.8)
