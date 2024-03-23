extends Camera2D

@export var shakefade: float = 10.0

var rng = RandomNumberGenerator.new()
var shake_strength: float = 0.0
var zoomed_out = false
var zoomed_in = true

func apply_shake(power, duration):
	shakefade -= 10
	shake_strength += power
	await get_tree().create_timer(duration, false).timeout
	shakefade += 10

func _physics_process(_delta):
	if not get_tree().has_group("stop following player"):
		position.x = get_node("../player").position.x
		position.y = get_node("../player").position.y

func _process(delta):
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, clamp(shakefade, 0, 10) * delta)
		offset = randomoffset()
	if get_tree().has_group("enemy") or get_tree().has_group("spawn"):
		if zoomed_out == false and not get_tree().has_group("stop following player"):
			zoom_out()
			zoomed_out = true
			zoomed_in = false
	elif zoomed_in == false and not get_tree().has_group("stop following player"):
		zoom_in()
		zoomed_in = true
		zoomed_out = false

func randomoffset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength),rng.randf_range(-shake_strength, shake_strength))

func zoom_out():
	var tween = create_tween().set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "zoom", Vector2(0.75, 0.75), 1)

func zoom_in():
	var tween = create_tween().set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "zoom", Vector2(1, 1), 1)
