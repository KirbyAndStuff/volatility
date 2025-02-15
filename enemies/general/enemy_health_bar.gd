extends Node2D

@export var event = "0"
@export var background_color = Color(0, 0, 0, 1)
@export var fill_color = Color(1, 1, 1, 1)
@export var fill_color2 = Color(1, 1, 1, 1)
@export var namea = "0"
@export var title = "0"
var dead = false

func _ready() -> void:
	if get_tree().has_group(event):
		$ProgressBar2.max_value = get_tree().get_first_node_in_group(event).max_health
		$ProgressBar.max_value = get_tree().get_first_node_in_group(event).max_health
	var sb_fill = StyleBoxFlat.new()
	sb_fill.bg_color = fill_color
	$ProgressBar.add_theme_stylebox_override("fill", sb_fill)
	var sb_back = StyleBoxFlat.new()
	sb_back.bg_color = background_color
	$ProgressBar.add_theme_stylebox_override("background", sb_back)
	var sb_fill2 = StyleBoxFlat.new()
	sb_fill2.bg_color = fill_color2
	$ProgressBar2.add_theme_stylebox_override("fill", sb_fill2)
	$Label.text = namea
	$title.text = title

func _process(_delta):
	if get_tree().has_group(event):
		$ProgressBar.value = get_tree().get_first_node_in_group(event).health
		if get_tree().get_first_node_in_group(event).health <= 0:
			die()
	else:
		die()

func die():
	if dead == false:
		dead = true
		create_tween().tween_property(self, "modulate", Color(0, 0, 0, 0), 1)
		remove_from_group("health_bar")
		await get_tree().create_timer(1, false).timeout
		queue_free()

func _on_progress_bar_value_changed(value: float) -> void:
	create_tween().set_trans(Tween.TRANS_EXPO).tween_property($ProgressBar2, "value", $ProgressBar.value, clamp(0.3 + ($ProgressBar2.value - $ProgressBar.value) / 10, 0, 1))
