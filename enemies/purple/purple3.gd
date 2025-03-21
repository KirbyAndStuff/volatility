extends CharacterBody2D

var purple_hurt := preload("res://enemies/purple/purple_hurt3.tscn")

func _ready():
	await get_tree().create_timer(0.3, false).timeout
	$playerdeath/CollisionShape2D.disabled = false
	$hurts_player/CollisionShape2D.disabled = false

var speed = 700
var health = 1.0
var max_health = 1.0
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
		var effect := purple_hurt.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		if health <= 0:
			emit_signal("died")
			queue_free()
	if area.is_in_group("parry") and guarded == false:
		$hurts_player.add_to_group("parried")
		speed = 0
		$eye.speed_scale = 0.1
		$Stunned.start()

func _on_stunned_timeout():
	$hurts_player.remove_from_group("parried")
	$eye.speed_scale = 1
	speed = 700
