extends Camera2D

@export var randomstrength: float = 10.0
@export var shakefade: float = 10.0

var rng = RandomNumberGenerator.new()

var shake_strength: float = 0.0

func apply_shake():
	shake_strength = randomstrength

func _physics_process(_delta):
	position.x = get_node("../player").position.x
	position.y = get_node("../player").position.y

func _process(delta):
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shakefade * delta)
		offset = randomoffset()
	if get_tree().has_group("screen_shake 10"):
		randomstrength = 10
		apply_shake()
	if get_tree().has_group("screen_shake 5"):
		randomstrength = 5
		apply_shake()
	if get_tree().has_group("enemy") or get_tree().has_group("spawn"):
		var tween = create_tween()
		tween.tween_property(self, "zoom", Vector2(0.75, 0.75), 1)
	else:
		var tween = create_tween()
		tween.tween_property(self, "zoom", Vector2(1, 1), 1)

func randomoffset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength),rng.randf_range(-shake_strength, shake_strength))
