extends Camera2D

@export var shakefade: float = 10.0

var rng = RandomNumberGenerator.new()
var shake_strength: float = 0.0
var strength_limit: float = 0.0
var zoomed_out = false
var zoomed_in = true
var speed = 3000
var snap = true
var shake_activators = 0
var const_shake = 0
var const_shake_num = 1

@onready var target = get_node("../player")

func apply_shake(power, duration):
	shake_activators += 1
	shakefade = 0
	if strength_limit < power:
		strength_limit = power
	shake_strength = clamp(shake_strength + power, 0, strength_limit)
	await get_tree().create_timer(duration, false).timeout
	shake_activators -= 1
	if shake_activators < 1:
		strength_limit = 0
		shakefade = 10

func _physics_process(delta):
	if not get_tree().has_group("stop following player"):
		if snap:
			global_position = target.global_position
		else:
			speed += 3000 * delta
			global_position += (target.global_position - global_position).normalized() * speed * delta
	#if const_shake > 0:
		#offset = randomconstoffset()
	#if shake_strength > 0 and const_shake == 0:
		#shake_strength = lerpf(shake_strength, 0, shakefade * delta)
		#offset = randomoffset()
	if shake_strength > 0 or const_shake > 0:
		shake_strength = lerpf(shake_strength, 0, shakefade * delta)
		offset = randomoffset() + randomconstoffset()
	if const_shake_num > 0 and const_shake > 0:
		const_shake = lerpf(const_shake, 0, 10 * delta)

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

func randomconstoffset() -> Vector2:
	return Vector2(rng.randf_range(-const_shake, const_shake),rng.randf_range(-const_shake, const_shake))

func zoom_out():
	var tween = create_tween().set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "zoom", Vector2(0.75, 0.75), 1)
	#tween.tween_property(self, "zoom", Vector2(0.5, 0.5), 1)

func zoom_in():
	var tween = create_tween().set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "zoom", Vector2(1, 1), 1)

func _on_snap_area_entered(area):
	if area.is_in_group("snap camera"):
		snap = true
		speed = 3000
		area.remove_from_group("snap camera")
