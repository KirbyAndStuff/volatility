extends Area2D

@export var event = "0"
@export var target = "0"
@export var size = 1.0
@export var stationary = false
@export var layer_and_mask = 1
var dead = false

func _ready():
	if stationary:
		$StaticBody2D/CollisionShape2D.disabled = false
	else:
		$StaticBody2D/CollisionShape2D.disabled = true
	scale = Vector2(size, size)
	$StaticBody2D.set_collision_layer_value(layer_and_mask, false)
	$StaticBody2D.set_collision_mask_value(layer_and_mask, false)
	create_tween().tween_property($CPUParticles2D, "modulate", Color(1, 1, 1, 1), 1)

func _process(_delta):
	if get_tree().has_group(event) and get_tree().has_group(target):
		if stationary == false:
			global_position = get_tree().get_first_node_in_group(target).global_position
		if get_tree().get_first_node_in_group(target).guarded == false:
			get_tree().get_first_node_in_group(target).guarded = true
	if not get_tree().has_group(event) and dead == false:
		dead = true
		if get_tree().has_group(target):
			get_tree().get_first_node_in_group(target).guarded = false
		create_tween().tween_property($CPUParticles2D, "modulate", Color(0, 0, 0, 0), 1)
		await get_tree().create_timer(1, false).timeout
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("player_attack") and stationary:
		if area.get_parent().has_method("die"):
			area.get_parent().die()
