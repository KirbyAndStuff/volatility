extends Camera2D

@export var shakefade: float = 10.0

var rng = RandomNumberGenerator.new()
var shake_strength: float = 0.0
var zoomed_out = false
var zoomed_in = true
var speed = 3000
var snap = true

@onready var target = get_node("../player")

func apply_shake(power, duration):
	shakefade = clamp(shakefade - 10, 0, 10)
	shake_strength += power
	await get_tree().create_timer(duration, false).timeout
	shakefade = clamp(shakefade + 10, 0, 10)

func _physics_process(delta):
	if not get_tree().has_group("stop following player"):
		if snap:
			global_position = target.global_position
		else:
			global_position += (target.global_position - global_position).normalized() * speed * delta
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shakefade * delta)
		offset = randomoffset()

func _process(_delta):
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

func _on_snap_area_entered(area):
	if area.is_in_group("snap camera"):
		snap = true
		area.remove_from_group("snap camera")
