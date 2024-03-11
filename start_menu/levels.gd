extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_pressed():
	$Panel.visible = !$Panel.visible

func _on_level_1_pressed() -> void:
	get_tree().change_scene_to_file("res://level_stuff/levels/level_1.tscn")

func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://level_stuff/levels/tutorial.tscn")
