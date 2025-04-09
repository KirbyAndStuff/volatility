extends Node2D

@onready var player = get_node("../player")
@onready var offset
@onready var cooldown_amount = 5
var sfx := preload("res://player/attacks/melee/meleem2_attack_sfx.tscn")
var damage = 2
var square_collision_pos = Vector2(17, 0)

func _process(_delta):
	position = get_node("../player").position + offset

func _ready():
	get_node("../camera").apply_shake(3, 0.1)
	var effect := sfx.instantiate()
	effect.position = position
	#effect.pitch_scale = 2
	#effect.volume_db = -5
	get_parent().add_child(effect)
	#look_at(player.global_position + Vector2(randf_range(-60, 60), randf_range(-60, 60)))
	look_at(player.global_position)
	$CPUParticles2D.emitting = true
	$Area2D/CollisionShape2D.position = square_collision_pos
	await get_tree().create_timer(0.2, false).timeout
	queue_free()

func _on_area_2d_area_entered(area):
	if area.is_in_group("enemy_body") and not area.is_in_group("no heal_cooldown reduction") and area.get_parent().guarded == false:
		get_node("../player").add_heal_cooldown(cooldown_amount)
	if area.is_in_group("enemy_attack") and area.get_parent().has_method("die"):
		area.get_parent().die()
