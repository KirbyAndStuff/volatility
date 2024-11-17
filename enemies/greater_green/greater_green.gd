extends CharacterBody2D

var speed = 2000
var is_moving = false
var is_attacking = false
var near_player = false
var health = 30.0
var guarded = false
var hurt := preload("res://enemies/greater_green/greater_green_hurt.tscn")

var used_bullet = false
var used_laser = true
var used_blast = 0

var spawn_point_count = 12
var radius = 1

func _ready():
	var step = 2 * PI / spawn_point_count
	for i in range(spawn_point_count):
		var spawn_point = Node2D.new()
		var pos = Vector2(radius, 0).rotated(step * i)
		spawn_point.position = pos
		spawn_point.rotation = pos.angle()
		$Node2D.add_child.call_deferred(spawn_point)

func _process(_delta):
	if health < 1:
		queue_free()
	if $BlastTimer.is_stopped() and near_player and is_attacking == false and used_blast < 2:
		is_attacking = true
		used_blast += 1
		$blastsfx.play()
		var bullet_scene = preload("res://enemies/greater_green/greater_green_blast.tscn")
		var shot = bullet_scene.instantiate()
		get_parent().add_child(shot)
		shot.shoot(global_position, get_node("../player").global_position)
		is_moving = true
		$BlastTimer.start()
	if $BulletTimer.is_stopped() and is_attacking == false and used_bullet == false:
		is_attacking = true
		used_bullet = true
		$BulletTimer.start()
		bullets(0)
		bullets(2)
		bullets(4)
		bullets(6)
	if $LaserTimer.is_stopped() and is_attacking == false and used_laser == false:
		is_attacking = true
		used_laser = true
		$LaserTimer.start()
		lasers(0)
		lasers(1)
		lasers(2)
		lasers(3)

func _physics_process(delta):
	if is_moving:
		if speed > 0:
			speed -= 2000 * delta
		position -= (get_node("../player").position - position).normalized() * speed * delta
		move_and_slide()

func _on_blast_timer_timeout():
	is_moving = false
	speed = 2000
	is_attacking = false

func _on_blast_area_area_entered(area):
	if area.is_in_group("player"):
		near_player = true

func _on_blast_area_area_exited(area):
	if area.is_in_group("player"):
		near_player = false

func bullets(delay):
	await get_tree().create_timer(delay, false).timeout
	$Node2D.rotation_degrees = randf_range(-360, 360)
	for s in $Node2D.get_children():
		var bullet_scene = preload("res://enemies/greater_green/greater_green_bullet.tscn")
		var shot = bullet_scene.instantiate()
		get_parent().add_child(shot)
		shot.position = s.global_position
		shot.rotation = s.global_rotation
	get_node("../camera").apply_shake(10, 0.5)
	$bulletsfx.play()
	$bulletsfx2.play()
	await get_tree().create_timer(2, false).timeout
	if delay == 6:
		is_attacking = false
		used_blast = 0
		used_laser = false

func lasers(delay):
	await get_tree().create_timer(delay, false).timeout
	var bullet_scene = preload("res://enemies/greater_green/greater_green_laser.tscn")
	var shot = bullet_scene.instantiate()
	get_parent().add_child(shot)
	shot.shoot(global_position, get_node("../player").global_position)
	await get_tree().create_timer(0.1, false).timeout
	$lasersfx.play()
	await get_tree().create_timer(3, false).timeout
	if delay == 3:
		is_attacking = false
		used_blast = 0
		used_bullet = false

func _on_playerdeath_area_entered(area):
	if area.is_in_group("player_attack") and guarded == false:
		if health > 1:
			var effect := hurt.instantiate()
			effect.position = position
			get_parent().add_child(effect)
		health -= area.get_parent().damage
