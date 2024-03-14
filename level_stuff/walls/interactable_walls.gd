extends TileMap

func _process(_delta):
	if get_parent().interacted:
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color(0, 0, 0, 0), 1)
		get_node("../../body_interactable/CollisionShape2D").disabled = true
	else:
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 1)
		get_node("../../body_interactable/CollisionShape2D").disabled = false
