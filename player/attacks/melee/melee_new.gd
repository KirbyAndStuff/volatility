extends Node2D

var directiona := Vector2.ZERO
var sfx := preload("res://player/attacks/melee/melee_sfx.tscn")
var damage = 2
var melee_order = 1
@onready var meleesemitting = [$melee1.emitting, $melee2.emitting, $melee3.emitting, $melee4.emitting, $melee5.emitting]

func _ready():
	var effect := sfx.instantiate()
	effect.position = get_node("../player").position
	effect.pitch_scale = 1.25
	get_parent().add_child(effect)
	$melee1.emitting = true
	$melee1_hurtbox/CollisionPolygon2D.disabled = false
	$melee1_hurtbox/CollisionShape2D.disabled = false
	$DieTimer.start()
	$HitBoxGoAway.start()

func _process(_delta):
	if not get_node("../player").active_weapon == 2:
		queue_free()
	position = get_node("../player").position
	if Input.is_action_pressed("left_mouse_button") and $WaitPlease.is_stopped() and not true in meleesemitting:
		$DieTimer.stop()
		$HitBoxGoAway.stop()
		$DieTimer.wait_time = 0.5
		$HitBoxGoAway.wait_time = 0.25
		#if melee_order == 0:
			#shoot(global_position, get_global_mouse_position())
			#$melee5.emitting = true
			#var effect := sfx.instantiate()
			#effect.position = get_node("../player").position
			#effect.pitch_scale = 2
			#get_parent().add_child(effect)
		if melee_order == 1:
			damage = 2
			shoot(global_position, get_global_mouse_position())
			$melee2.emitting = true
			$melee1_hurtbox/CollisionPolygon2D.disabled = false
			$melee1_hurtbox/CollisionShape2D.disabled = false
			var effect := sfx.instantiate()
			effect.position = get_node("../player").position
			effect.pitch_scale = 2
			get_parent().add_child(effect)
			#$WaitPlease.wait_time = 0.2
		if melee_order == 2:
			shoot(global_position, get_global_mouse_position())
			$melee3.emitting = true
			$melee1_hurtbox/CollisionPolygon2D.disabled = false
			$melee1_hurtbox/CollisionShape2D.disabled = false
			var effect := sfx.instantiate()
			effect.position = get_node("../player").position
			effect.pitch_scale = 2
			get_parent().add_child(effect)
			$DieTimer.wait_time = 0.75
			$WaitPlease.wait_time = 0.5
			$HitBoxGoAway.wait_time = 0.3
			#$DieTimer.wait_time = 0.75
			#$WaitPlease.wait_time = 0.3
		if melee_order == 3:
			a()
		$WaitPlease.start()
		$DieTimer.start()
		$HitBoxGoAway.start()
		melee_order += 1

func shoot(from: Vector2, to: Vector2):
	global_position = from
	directiona = from.direction_to(to)
	rotation = directiona.angle()

func _on_die_timer_timeout() -> void:
	queue_free()

func _on_melee_1_hurtbox_area_entered(area):
	if area.is_in_group("enemy_body"):
		$melee1_hurtbox/CollisionPolygon2D.set_deferred("disabled", true)
		$melee1_hurtbox/CollisionShape2D.set_deferred("disabled", true)
		if not area.is_in_group("no heal_cooldown reduction") and (get_node("../player").heal_cooldown) < 100 and area.get_parent().guarded == false:
			(get_node("../player").heal_cooldown) = clamp((get_node("../player").heal_cooldown) + 5, 0, 100)

func _on_melee_4_hurtbox_area_entered(area):
	if area.is_in_group("enemy_body") and not area.is_in_group("no heal_cooldown reduction") and (get_node("../player").heal_cooldown) < 100 and area.get_parent().guarded == false:
		(get_node("../player").heal_cooldown) = clamp((get_node("../player").heal_cooldown) + 5, 0, 100)

func _on_hit_box_go_away_timeout():
	$melee1_hurtbox/CollisionPolygon2D.set_deferred("disabled", true)
	$melee1_hurtbox/CollisionShape2D.set_deferred("disabled", true)
	$melee4_hurtbox/CollisionPolygon2D.set_deferred("disabled", true)

func a():
			damage = 3
			get_node("../camera").apply_shake(5, 0.25)
			shoot(global_position, get_global_mouse_position())
			$melee4.emitting = true
			$melee4_hurtbox/CollisionPolygon2D.disabled = false
			var effect := sfx.instantiate()
			effect.position = get_node("../player").position
			effect.pitch_scale = 1
			get_parent().add_child(effect)
			#$DieTimer.wait_time = 0.3
			b()

func b():
			await get_tree().create_timer(0.07, false).timeout
			$melee8.emitting = true
