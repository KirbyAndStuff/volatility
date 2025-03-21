extends Area2D

var sfx := preload("res://player/attacks/melee/meleem2_attack_sfx.tscn")
var damage = 3
@onready var cooldown_amount = 5

func _ready():
	get_node("../camera").apply_shake(5, 0.1)
	var effect := sfx.instantiate()
	effect.position = position
	get_parent().add_child(effect)
	rotation = randf_range(-180, 180)
	$CPUParticles2D.emitting = true
	if get_tree().has_group("marked melee_m2"):
		global_position = get_tree().get_first_node_in_group("marked melee_m2").global_position
	else:
		global_position = get_node("../meleem2/Area2D").global_position
	await get_tree().create_timer(0.2, false).timeout
	queue_free()

func _on_area_2d_area_entered(area):
	if area.is_in_group("enemy_body") and not area.is_in_group("no heal_cooldown reduction") and area.get_parent().guarded == false:
		get_node("../player").add_heal_cooldown(cooldown_amount)
