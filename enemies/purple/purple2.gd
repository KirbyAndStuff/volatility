extends CharacterBody2D

var purple_hurt := preload("res://enemies/purple/purple_hurt2.tscn")
var purple3 := preload("res://enemies/purple/purple3.tscn")
var death := preload("res://enemies/purple/purple_death_2.tscn")

func _ready():
	await get_tree().create_timer(0.3, false).timeout
	$playerdeath/CollisionShape2D.disabled = false
	$hurts_player/CollisionShape2D2.disabled = false
	$hurts_player/CollisionShape2D3.disabled = false

var speed = 500
var health = 2.0
var max_health = 2.0
var guarded = false

signal health_changed(new_health)
signal died

func _physics_process(_delta):
	var direction = (get_node("../player").position-position).normalized()
	velocity=direction*speed
	move_and_slide()

func _on_playerdeath_area_entered(area):
	if area.is_in_group("player_attack") and guarded == false:
		health -= area.get_parent().damage
		emit_signal("health_changed", health)
		if health > 0:
			var effect := purple_hurt.instantiate()
			effect.position = position
			get_parent().add_child(effect)
		else:
			emit_signal("died")
			var effect := death.instantiate()
			effect.position = position
			get_parent().add_child(effect)
			var purple3_1 := purple3.instantiate()
			var purple3_2 := purple3.instantiate()
			
			var offset = Vector2(50, 0)
			purple3_1.position = position - offset
			purple3_2.position = position + offset
			
			call_deferred("add_sibling", purple3_1)
			call_deferred("add_sibling", purple3_2)
			
			queue_free()
	if area.is_in_group("parry") and guarded == false:
		$hurts_player.add_to_group("parried")
		speed = 0
		$eye_left.speed_scale = 0.1
		$eye_right.speed_scale = 0.1
		$Stunned.start()

func _on_stunned_timeout():
	$hurts_player.remove_from_group("parried")
	$eye_left.speed_scale = 0.75
	$eye_right.speed_scale = 0.75
	speed = 500
