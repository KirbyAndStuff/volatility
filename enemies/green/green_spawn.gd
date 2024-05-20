extends CPUParticles2D

var spawn_green := preload("res://enemies/green/green.tscn")
var player_detected = false
@export var event = "0"

func _process(_delta):
	if not get_tree().has_group("cant spawn enemy") and player_detected:
		spawn_enemy()
		player_detected = false

func _on_area_2d_area_entered(area):
	if area.is_in_group("player"):
		player_detected = true

func _on_wall_check_body_entered(body):
	if body.is_in_group("wall"):
		get_parent().give_credit = true
		queue_free()

func _ready():
	await get_tree().create_timer(1, false).timeout
	$Area2D/CollisionShape2D.disabled = false

func spawn_enemy():
	$wall_check.add_to_group("spawn")
	emitting = false
	await get_tree().create_timer(1, false).timeout
	var effect := spawn_green.instantiate()
	effect.position = position
	effect.add_to_group(event)
	get_parent().call_deferred("add_child", effect)
	queue_free()
