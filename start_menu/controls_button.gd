extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("left_mouse_button"):
		$controls_panel.visible = false


func _on_pressed():
	$controls_panel.visible = !$controls_panel.visible
