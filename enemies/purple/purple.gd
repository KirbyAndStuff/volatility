extends CharacterBody2D

var purple_hurt := preload("res://enemies/purple/purple_hurt1.tscn")
var purple2 := preload("res://enemies/purple/purple2.tscn")
var death := preload("res://enemies/purple/purple_death_1.tscn")

func _ready():
	$spawnsfx.global_position = get_node("../player").global_position
	$spawn.emitting = true
	await  $spawn.finished
	$spawn.queue_free()

var speed = 300
var health = 3.0
var guarded = false

@onready var eyes = [$eye_bottom, $eye_top, $eye_left, $eye_right]

func _physics_process(_delta):
	var direction = (get_node("../player").position-position).normalized()
	velocity=direction*speed
	move_and_slide()

func _process(_delta):
	if health <= 0:
		var effect := death.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		var purple2_1 := purple2.instantiate()
		var purple2_2 := purple2.instantiate()
		
		var offset = Vector2(50, 0)
		purple2_1.position = position - offset
		purple2_2.position = position + offset
		purple2_2.rotation = 90
		
		get_parent().add_child(purple2_1)
		get_parent().add_child(purple2_2)
		queue_free()

func _on_playerdeath_area_entered(area):
	if area.is_in_group("player_attack") and guarded == false:
		if health > 1:
			var effect := purple_hurt.instantiate()
			effect.position = position
			get_parent().add_child(effect)
		health -= area.get_parent().damage
	if area.is_in_group("parry") and guarded == false:
		$hurts_player.add_to_group("parried")
		speed = 0
		for vol in eyes:
			vol.speed_scale = 0.1
		$Stunned.start()

func _on_stunned_timeout():
	$hurts_player.remove_from_group("parriedeffect.sfx_big_db = -2")
	for vol in eyes:
		vol.speed_scale = 0.5
	speed = 300
