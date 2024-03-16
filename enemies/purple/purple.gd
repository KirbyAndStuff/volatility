extends CharacterBody2D

var purple_hurt := preload("res://enemies/purple/purple_hurt1.tscn")
var purple2 := preload("res://enemies/purple/purple2.tscn")
var deathsfx := preload("res://enemies/purple/purple_death1sfx.tscn")

func _ready():
	var effect := purple_hurt.instantiate()
	effect.position = position
	get_parent().call_deferred("add_child", effect)

var speed = 300
var player_chase = false
var player = null
var attack_player = false
var purple_health = 3
var is_stunned = false

@onready var eyes = [$eye_bottom, $eye_top, $eye_left, $eye_right]

func _physics_process(_delta):
	if player_chase:
		var direction = (player.position-position).normalized()
		velocity=direction*speed
		move_and_slide()

func _process(_delta):
	if attack_player and (get_node("../player").attackable) == true and is_stunned == false:
		(get_node("../player").health) -= 1
		(get_node("../player").i_frames(1))
		(get_node("../player").player_hurt_particles())
		(get_node("../player").framefreeze(0.4, 0.3))
	if purple_health < 1:
		var effect := deathsfx.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		
		var purple2_1 := purple2.instantiate()
		var purple2_2 := purple2.instantiate()
		
		var offset = Vector2(50, 0)
		purple2_1.position = position - offset
		purple2_2.position = position + offset
		
		get_parent().add_child(purple2_1)
		get_parent().add_child(purple2_2)
		queue_free()

func _on_playerdeath_area_entered(area):
	if area.is_in_group("player_attack"):
		var effect := purple_hurt.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		purple_health -= area.get_parent().damage
	if area.is_in_group("parry"):
		speed = 0
		for vol in eyes:
			vol.speed_scale = 0.1
		$Stunned.start()

func _on_stunned_timeout():
	for vol in eyes:
		vol.speed_scale = 0.75
	is_stunned = false
	speed = 300

func _on_player_detection_area_entered(area):
	if area.is_in_group("player") and is_stunned == false:
		player = area.get_parent()
		player_chase = true

func _on_player_detection_area_exited(area):
	if area.is_in_group("player"):
		player = null
		player_chase = false

func _on_hurts_player_area_entered(area):
	if area.is_in_group("player"):
		attack_player = true

func _on_hurts_player_area_exited(area):
	if area.is_in_group("player"):
		attack_player = false
