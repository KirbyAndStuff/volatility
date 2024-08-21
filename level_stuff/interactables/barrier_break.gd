extends Area2D

var health = 3.0
var can_be_hurt_view = false
var can_be_hurt_enemy = false
var barrier_hurt := preload("res://enemies/green/green_hurt.tscn")
var screen_size
@export var event = "0"

func _ready():
	add_to_group(event)
	screen_size = get_viewport_rect().size

func _process(_delta):
	if health < 1:
		$CPUParticles2D.emitting = false
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color(0, 0, 0, 0), 1)
		remove_from_group(event)
		await get_tree().create_timer(1, false).timeout
		queue_free()
	var location_dif = global_position - get_node("../player").global_position
	if abs(location_dif.x) > (screen_size.x/2) * 1 || abs(location_dif.y) > (screen_size.y/2) * 1:
		can_be_hurt_view = false
	else:
		can_be_hurt_view = true
	if not get_tree().has_group("ignore enemy"):
		if get_tree().has_group("enemy") or get_tree().has_group("spawn") or get_tree().has_group("enemy_attack"):
			can_be_hurt_enemy = false
		else:
			can_be_hurt_enemy = true
	else:
		can_be_hurt_enemy = true
	if can_be_hurt_view and can_be_hurt_enemy:
		$CPUParticles2D.modulate = Color(1, 1, 1, 1)
	else:
		$CPUParticles2D.modulate = Color(1, 1, 1, 0.1)

func _on_area_entered(area):
	if area.is_in_group("player_attack") and can_be_hurt_view == true and can_be_hurt_enemy:
		var effect := barrier_hurt.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		effect.die(0.5)
		$hurt.play()
		health -= area.get_parent().damage
