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
