extends Node2D

@onready var smack_lines = [$smack_line1, $smack_line2, $smack_line3, $smack_line4]
@onready var sfx
@onready var loud
@onready var speed

func _ready():
	$sfx.pitch_scale = sfx
	$sfx.volume_db = loud
	for vol in smack_lines:
		vol.speed_scale = speed
	for vol in smack_lines:
		vol.emitting = true
	await $smack_line1.finished
	$hitbox/strike.disabled = true
	await $sfx.finished
	queue_free()
