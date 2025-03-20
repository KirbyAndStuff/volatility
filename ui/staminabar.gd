extends Control

var stamina_actual = true

func _ready() -> void:
	position = Vector2(56, 960)
	get_node("../../player").connect("stamina_tween", tween_stamina)

func _process(_delta):
	if stamina_actual == true:
		$stamina_bar2.value = 0 - (get_node("../../player").stamina)
	if $stamina_bar2.value > -50 and not $filling.color == Color(1, 0, 0):
		$filling.color = Color(1, 0, 0)
	if $stamina_bar2.value < -50 and not $filling.color == Color(0, 0.827, 1):
		$filling.color = Color(0, 0.827, 1)

func tween_stamina():
	stamina_actual = false
	create_tween().tween_property($stamina_bar2, "value", $stamina_bar2.value + 50, 0.075)
	await get_tree().create_timer(0.075, false).timeout
	stamina_actual = true
