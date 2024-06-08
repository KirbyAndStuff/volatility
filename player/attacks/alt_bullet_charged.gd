extends Area2D

var sfx := preload("res://player/attacks/meleem2_attack_sfx.tscn")
var damage = 2
@onready var blades = [$CPUParticles2D, $CPUParticles2D2, $CPUParticles2D3, $CPUParticles2D4]

func _ready():
	get_node("../camera").apply_shake(5, 0.1)
	var effect := sfx.instantiate()
	effect.position = position
	effect.volume_db = 0
	get_parent().add_child(effect)
	rotation = randf_range(-180, 180)
	for vol in blades:
		vol.emitting = true
	await get_tree().create_timer(0.2, false).timeout
	queue_free()

func _on_area_2d_area_entered(area):
	if area.is_in_group("enemy_body") and not area.is_in_group("no heal_cooldown reduction") and (get_node("../player").heal_cooldown) < 100 and area.get_parent().guarded == false:
		(get_node("../player").heal_cooldown) = clamp((get_node("../player").heal_cooldown) + 5, 0, 100)
