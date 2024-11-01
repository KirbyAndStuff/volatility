extends Node2D

@onready var player = get_node("../player")
@onready var offset
var sfx := preload("res://player/attacks/melee/meleem2_attack_sfx.tscn")
var damage = 2

func _process(_delta):
	position = get_node("../player").position + offset

func _ready():
	get_node("../camera").apply_shake(3, 0.1)
	var effect := sfx.instantiate()
	effect.position = position
	#effect.pitch_scale = 2
	#effect.volume_db = -5
	get_parent().add_child(effect)
	look_at(player.global_position + Vector2(randf_range(-60, 60), randf_range(-60, 60)))
	#look_at(player.global_position)
	$CPUParticles2D.emitting = true
	await get_tree().create_timer(0.2, false).timeout
	queue_free()

func _on_area_2d_area_entered(area):
	if area.is_in_group("enemy_body") and not area.is_in_group("no heal_cooldown reduction") and (get_node("../player").heal_cooldown) < 100 and area.get_parent().guarded == false:
		(get_node("../player").heal_cooldown) = clamp((get_node("../player").heal_cooldown) + 5, 0, 100)
