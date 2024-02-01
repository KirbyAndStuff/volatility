extends Control

func _process(_delta):
	var health = (get_node("../../player").health)
	if health < 3:
		$health3.emitting = false
	else:
		$health3.emitting = true
	if health < 2:
		$health2.emitting = false
	else:
		$health2.emitting = true
	if health < 1:
		$health.emitting = false
	else:
		$health.emitting = true
	var volatility = (get_node("../../player").volatility)
	if 1 <= volatility:
		$volatility.emitting = true
	else:
		$volatility.emitting = false
	if 2 <= volatility:
		$volatility2.emitting = true
	else:
		$volatility2.emitting = false
	if 3 <= volatility:
		$volatility3.emitting = true
	else:
		$volatility3.emitting = false
	if 4 <= volatility:
		$volatility4.emitting = true
	else:
		$volatility4.emitting = false
	if 5 <= volatility:
		$volatility5.emitting = true
	else:
		$volatility5.emitting = false
	if Input.is_action_pressed("parry") and $Parry_Cooldown.is_stopped():
		$parry_ready.emitting = false
		$parry_ready2.emitting = false
		$parry.modulate = Color(0, 0, 0, 0)
		var tween = create_tween()
		tween.tween_property($parry, "modulate", Color(1, 1, 1), 3)
		$Parry_Cooldown.start()

func _on_parry_cooldown_timeout() -> void:
	$parry_ready.emitting = true
	$parry_ready2.emitting = true
