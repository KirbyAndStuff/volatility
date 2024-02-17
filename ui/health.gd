extends Control

@onready var healthEmitters = [$health, $health2, $health3]
@onready var volatilityEmitters = [$volatility, $volatility2, $volatility3, $volatility4, $volatility5]
@onready var parry := $parry

func _process(_delta):
	var health = (get_node("../../player").health)
	for i in range(0, healthEmitters.size()):
		healthEmitters[i].emitting = i < health

	var volatility = (get_node("../../player").volatility)
	for i in range(0, volatilityEmitters.size()):
		volatilityEmitters[i].emitting = i + 1 <= volatility

	if (get_node("../../player").parrytimer).is_stopped():
		$parry_ready.emitting = true
		$parry_ready2.emitting = true
		$parry.modulate = Color(1, 1, 1, 1)
	else:
		$parry_ready.emitting = false
		$parry_ready2.emitting = false
		$parry.modulate = Color(0, 0, 0, 0)
