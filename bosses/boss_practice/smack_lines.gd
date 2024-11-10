extends Node2D

var attack_player = false
@onready var smack_lines = [$smack_line1, $smack_line2, $smack_line3, $smack_line4]
@onready var sfx
@onready var loud

func _ready():
	$sfx.pitch_scale = sfx
	$sfx.volume_db = loud
	for vol in smack_lines:
		vol.emitting = true
	await $smack_line1.finished
	$hitbox/strike.disabled = true
	await $sfx.finished
	queue_free()

func _process(_delta):
	if attack_player and (get_node("../player").amount_of_i_frames) < 1:
		(get_node("../player").health) -= 1
		(get_node("../player").i_frames(1))
		(get_node("../player").player_hurt_particles())
		(get_node("../player").framefreeze(0.4, 0.3))

func _on_hitbox_area_entered(area):
	if area.is_in_group("player"):
		attack_player = true

func _on_hitbox_area_exited(area):
	if area.is_in_group("player"):
		attack_player = false
