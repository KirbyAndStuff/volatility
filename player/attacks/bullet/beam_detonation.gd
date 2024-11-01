extends Area2D

var detonationsfx := preload("res://player/attacks/bullet/detonationsfx.tscn")
var damage = 3
var shake = 10

func _ready():
	if not get_tree().has_group("beam"):
		get_node("../camera").apply_shake(shake, 0.5)
		var effect := detonationsfx.instantiate()
		effect.position = position
		get_parent().add_child(effect)
	$CPUParticles2D.emitting = true
	await get_tree().create_timer(0.2, false).timeout
	$Area2D.queue_free()

func _on_timer_timeout() -> void:
	queue_free()

func _on_area_2d_area_entered(area):
	if area.is_in_group("enemy_body") and not area.is_in_group("no heal_cooldown reduction") and (get_node("../player").heal_cooldown) < 100:
		(get_node("../player").heal_cooldown) = clamp((get_node("../player").heal_cooldown) + 5, 0, 100)
