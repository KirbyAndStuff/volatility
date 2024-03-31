extends Node2D

var red_death := preload("res://enemies/red/red_death.tscn")
var red_hurt := preload("res://enemies/red/red_hurt.tscn")
var speed = 500
var health = 10

func _physics_process(delta):
	if speed <= 500:
		position += (get_node("../player").position - position).normalized() * speed * delta

func _on_area_2d_area_entered(area):
	if area.is_in_group("green meteor"):
		die()
	if area.is_in_group("player_attack"):
		var effect := red_hurt.instantiate()
		effect.position = position
		get_parent().add_child(effect)

func die():
	var effect := red_death.instantiate()
	effect.position = position
	get_parent().add_child(effect)
	queue_free()
