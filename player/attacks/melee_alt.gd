extends Area2D

var activate = false
var slashes = 0
var slash := preload("res://player/attacks/melee_alt_attack.tscn")

func _on_slash_timer_timeout() -> void:
	var effect := slash.instantiate()
	effect.position = position
	get_parent().add_child(effect)
	slashes += 1

func _process(_delta):
	position = get_node("../player").position
	if $SlashTimer.is_stopped() and activate:
		$SlashTimer.start()
	if slashes > 4:
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("enemy"):
		activate = true
		area.add_to_group("marked melee alt")

func _on_die_timer_timeout() -> void:
	queue_free()

func _on_area_exited(area):
	if area.is_in_group("enemy"):
		area.remove_from_group("marked melee alt")
