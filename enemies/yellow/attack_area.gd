extends CPUParticles2D

var attack_player = false
var is_dead = false

func _ready():
	var tween = create_tween()
	tween.tween_property($attack_area_hurtbox/CollisionShape2D, "scale", Vector2(258, 258), 0.55)

func _process(_delta):
	if attack_player and is_dead == false and (get_node("../player").i_frames) == false and (get_node("../player").dashi_frames) == false:
		(get_node("../player").health) -= 1
		(get_node("../player").i_frames) = true
		(get_node("../player").player_hurt_particles())
		(get_node("../player").framefreeze(0.4, 0.3))

func _on_attack_area_hurtbox_body_entered(body):
	if body.name == "player":
		attack_player = true

func _on_attack_area_hurtbox_body_exited(body):
	if body.name == "player":
		attack_player = false

func _on_timer_timeout():
	emitting = false
	is_dead = true
	await get_tree().create_timer(1).timeout
	queue_free()
