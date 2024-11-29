extends CPUParticles2D

var damage = 0
var sfx_big = false
var sfx_big_db = -5
var sfx_big_ps = 0.6
var hurtbox_size = Vector2(1, 1)

func _ready():
	emitting = true
	#$hurtbox.scale = hurtbox_size
	create_tween().tween_property($hurtbox, "scale", hurtbox_size, 0.4)
	if sfx_big:
		$sfx.volume_db = 0
		$sfx_big.volume_db = sfx_big_db
		$sfx_big.pitch_scale = sfx_big_ps
		$sfx_big.play()
	await finished
	$hurtbox.queue_free()
	await $sfx.finished
	queue_free()

func _on_hurtbox_area_entered(area):
	if area.is_in_group("enemy_body"):
		if not area.is_in_group("no heal_cooldown reduction") and area.get_parent().guarded == false:
			get_node("../player").add_heal_cooldown(5)
