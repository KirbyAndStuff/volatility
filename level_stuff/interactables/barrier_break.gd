extends Area2D

var health = 3
var can_be_hurt_view = false
var can_be_hurt_enemy = false
var barrier_hurt := preload("res://enemies/green/green_hurt.tscn")
var screen_size

func _ready():
	screen_size = get_viewport_rect().size

func _process(_delta):
	if health < 1:
		$CPUParticles2D.emitting = false
		await get_tree().create_timer(1, false).timeout
		queue_free()
	var location_dif = global_position - get_node("../player").global_position
	if abs(location_dif.x) > (screen_size.x/2) * 1 || abs(location_dif.y) > (screen_size.y/2) * 1:
		can_be_hurt_view = false
	else:
		can_be_hurt_view = true
	if get_tree().has_group("enemy") or get_tree().has_group("spawn"):
		can_be_hurt_enemy = false
	else:
		can_be_hurt_enemy = true
	if can_be_hurt_view and can_be_hurt_enemy:
		$CPUParticles2D.modulate = Color(1, 1, 1, 1)
	else:
		$CPUParticles2D.modulate = Color(1, 1, 1, 0.1)

func _on_area_entered(area):
	if area.is_in_group("deal 1 damage") and can_be_hurt_view == true and can_be_hurt_enemy:
		var effect := barrier_hurt.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		$hurt.play()
		health -= 1
	if area.is_in_group("deal 2 damage") and can_be_hurt_view == true and can_be_hurt_enemy:
		var effect := barrier_hurt.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		$hurt.play()
		health -= 2
