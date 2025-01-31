extends CharacterBody2D

var direction = Vector2.ZERO
var speed = 2000
var is_attacking = false
var near_player = false
var health = 40.0
var guarded = false
var is_dead = true
var lerp_weight = 0.005
var play_intro = false
var hurt := preload("res://enemies/greater_green/greater_green_hurt.tscn")

var used_bullet = false
var used_laser = true
var used_blast = 0

var spawn_point_count = 16

func _ready():
	$body.emitting = false
	$eye.modulate = Color(0, 1, 0, 0)
	var step = 2 * PI / spawn_point_count
	for i in range(spawn_point_count):
		var spawn_point = Node2D.new()
		var pos = Vector2(1, 0).rotated(step * i)
		spawn_point.position = pos
		spawn_point.rotation = pos.angle()
		$Node2D.add_child.call_deferred(spawn_point)
	if play_intro:
		create_tween().tween_property($eye, "modulate", Color(0, 1, 0, 1), 4)
		await get_tree().create_timer(2, false).timeout
		$introsfx.play()
		create_tween().tween_property($introsfx, "volume_db", 5, 3.5)
		get_node("../camera").apply_shake(2, 2)
		await get_tree().create_timer(2, false).timeout
		get_node("../camera").apply_shake(5, 2)
		create_tween().tween_property($eye, "modulate", Color(1, 3, 1, 1), 2)
		await get_tree().create_timer(2, false).timeout
		$introsfx.stop()
		await get_tree().create_timer(0.5, false).timeout
		$body.emitting = true
		get_node("../camera").apply_shake(10, 0.5)
		$die_finalsfx.play()
		$bullet_explosion.emitting = true
		$playerdeath/CollisionShape2D.disabled = false
		await get_tree().create_timer(2, false).timeout
		$bullet_explosion.lifetime = 0.7
		$bullet_explosion.amount = 150
		is_dead = false
	else:
		$body.emitting = true
		$eye.modulate = Color(1, 3, 1, 1)
		get_node("../camera").apply_shake(10, 0.5)
		$die_finalsfx.play()
		$bullet_explosion.emitting = true
		$playerdeath/CollisionShape2D.disabled = false
		await get_tree().create_timer(2, false).timeout
		$bullet_explosion.lifetime = 0.7
		$bullet_explosion.amount = 150
		is_dead = false

func _process(_delta):
	if health <= 0 and is_dead == false:
		add_to_group("enemy")
		is_dead = true
		$playerdeath.queue_free()
		$bulletm2.queue_free()
		get_node("../camera").apply_shake(5, 0.3)
		create_tween().tween_property($eye, "modulate", Color(1, 1, 1, 0), 1.5)
		$die.position = Vector2(randf_range(-64, 64), randf_range(-64, 64))
		$die.emitting = true
		$diesfx.play()
		await get_tree().create_timer(0.51, false).timeout
		get_node("../camera").apply_shake(5, 0.3)
		$die.position = Vector2(randf_range(-64, 64), randf_range(-64, 64))
		$die.emitting = true
		$diesfx.play()
		await get_tree().create_timer(0.51, false).timeout
		get_node("../camera").apply_shake(5, 0.3)
		$die.position = Vector2(randf_range(-64, 64), randf_range(-64, 64))
		$die.emitting = true
		$diesfx.play()
		$body.emitting = false
		await get_tree().create_timer(1, false).timeout
		get_node("../camera").apply_shake(10, 1.5)
		$die_final.emitting = true
		$die_finalsfx.play()
		await get_tree().create_timer(1, false).timeout
		$die_final.emitting = false
		await get_tree().create_timer(0.5, false).timeout
		queue_free()
	if $BlastTimer.is_stopped() and near_player and is_attacking == false and used_blast < 2 and is_dead == false:
		$about_to_blast.emitting = true
		$about_to_blastsfx.play()
		is_attacking = true
		used_blast += 1
		$BlastTimer.start()
		blast(0.5)
	if $BulletTimer.is_stopped() and is_attacking == false and used_bullet == false and is_dead == false:
		$about_to_attack.emitting = true
		$about_to_attacksfx.play()
		is_attacking = true
		used_bullet = true
		$BulletTimer.start()
		bullets(false)
		await get_tree().create_timer(1, false).timeout
		bullets(false)
		await get_tree().create_timer(1, false).timeout
		bullets(false)
		await get_tree().create_timer(1, false).timeout
		bullets(true)
	if $LaserTimer.is_stopped() and is_attacking == false and used_laser == false and is_dead == false:
		$about_to_attack.emitting = true
		$about_to_attacksfx.play()
		is_attacking = true
		used_laser = true
		$LaserTimer.start()
		lasers(1)
		lasers(2)
		lasers(3)
		lasers(4)

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal())
	if not velocity == Vector2.ZERO:
		lerp_weight += 0.005 * delta
		velocity = lerp(velocity, Vector2.ZERO, lerp_weight)

func _on_blast_timer_timeout():
	velocity = Vector2.ZERO
	lerp_weight = 0.005
	is_attacking = false
	direction = Vector2.ZERO

func _on_blast_area_area_entered(area):
	if area.is_in_group("player"):
		near_player = true

func _on_blast_area_area_exited(area):
	if area.is_in_group("player"):
		near_player = false

func blast(delay):
	await get_tree().create_timer(delay, false).timeout
	if is_dead == false:
		$blastsfx.play()
		var bullet_scene = preload("res://enemies/greater_green/greater_green_blast.tscn")
		var shot = bullet_scene.instantiate()
		get_parent().add_child(shot)
		shot.shoot(global_position, get_node("../player").global_position)
		direction = (get_node("../player").global_position - global_position).normalized()
		velocity = direction * speed * -1

func bullets(last):
	if is_dead == false:
		$Node2D.rotation_degrees = randf_range(-360, 360)
		for s in $Node2D.get_children():
			var bullet_scene = preload("res://enemies/greater_green/bullet_telegraph.tscn")
			var shot = bullet_scene.instantiate()
			get_parent().add_child(shot)
			shot.position = s.global_position
			shot.rotation = s.global_rotation
		await get_tree().create_timer(1, false).timeout
	if is_dead == false:
		for s in $Node2D.get_children():
			var bullet_scene = preload("res://enemies/greater_green/greater_green_bullet.tscn")
			var shot = bullet_scene.instantiate()
			get_parent().add_child(shot)
			shot.position = s.global_position
			shot.rotation = s.global_rotation
		get_node("../camera").apply_shake(10, 0.5)
		$bulletsfx.play()
		$bulletsfx2.play()
		$bullet_explosion.emitting = true
		await get_tree().create_timer(2, false).timeout
		if last:
			is_attacking = false
			used_blast = 0
			used_laser = false

func lasers(delay):
	await get_tree().create_timer(delay, false).timeout
	if is_dead == false:
		var bullet_scene = preload("res://enemies/greater_green/greater_green_laser.tscn")
		var shot = bullet_scene.instantiate()
		get_parent().add_child(shot)
		shot.shoot(global_position, get_node("../player").global_position)
		await get_tree().create_timer(0.1, false).timeout
		$lasersfx.play()
		await get_tree().create_timer(3, false).timeout
		if delay == 4:
			is_attacking = false
			used_blast = 0
			used_bullet = false

func _on_playerdeath_area_entered(area):
	if area.is_in_group("player_attack") and guarded == false:
		if health > 1:
			var effect := hurt.instantiate()
			effect.position = position
			effect.get_child(0).pitch_scale = randf_range(1, 2)
			get_parent().add_child(effect)
		health -= area.get_parent().damage

func _on_introsfx_finished():
	$introsfx.play()
