extends CharacterBody2D

var direction = Vector2.ZERO
var speed = 1500
var attack_player = false

func _process(_delta):
	if attack_player and (get_node("../../player").amount_of_i_frames) < 1:
		(get_node("../../player").health) -= 1
		(get_node("../../player").i_frames(1))
		(get_node("../../player").player_hurt_particles())
		(get_node("../../player").framefreeze(0.4, 0.3))

func _on_hitbox_left_area_entered(area):
	if area.is_in_group("player"):
		attack_player = true

func _on_hitbox_left_area_exited(area):
	if area.is_in_group("player"):
		attack_player = false

func _on_hitbox_right_area_entered(area):
	if area.is_in_group("player"):
		attack_player = true

func _on_hitbox_right_area_exited(area):
	if area.is_in_group("player"):
		attack_player = false
