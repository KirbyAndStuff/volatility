extends CPUParticles2D

var attack_player = false

func _ready():
	var tween = create_tween()
	tween.tween_property($attack_area_hurtbox/CollisionShape2D, "scale", Vector2(258, 258), 0.75)

func _process(_delta):
	if attack_player and (get_node("../player").amount_of_i_frames) < 1:
		(get_node("../player").health) -= 1
		(get_node("../player").i_frames(1))
		(get_node("../player").player_hurt_particles())
		(get_node("../player").framefreeze(0.4, 0.3))
	if not get_tree().has_group("yellow"):
		emitting = false
		$attack_area_hurtbox/CollisionShape2D.disabled = true
		await get_tree().create_timer(1, false).timeout
		queue_free()

func _on_attack_area_hurtbox_body_entered(body):
	if body.name == "player":
		attack_player = true

func _on_attack_area_hurtbox_body_exited(body):
	if body.name == "player":
		attack_player = false

func _on_timer_timeout() -> void:
	emitting = false
	$attack_area_hurtbox/CollisionShape2D.disabled = true
	await get_tree().create_timer(1, false).timeout
	queue_free()
