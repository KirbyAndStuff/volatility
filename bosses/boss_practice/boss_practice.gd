extends CharacterBody2D

var direction = Vector2.ZERO
var speed = 3000
var arm := preload("res://bosses/boss_practice/boss_practice_arm.tscn")

#func _ready() -> void:
	#var effect1 := arm.instantiate()
	#effect1.position = position + Vector2(-400, 100)
	#effect1.scale = Vector2(1.5, 1.5)
	#var effect2 := arm.instantiate()
	#effect2.position = position + Vector2(400, 100)
	#effect2.scale = Vector2(1.5, 1.5)
	#effect2.is_left = false
	#get_parent().call_deferred("add_child", effect1)
	#get_parent().call_deferred("add_child", effect2)

func _ready():
	#$arm_left.position = Vector2(-400, 100)
	#$arm_right.position = Vector2(400, 100)
	#$arm_left.rotation_degrees = -36.5
	#$arm_right.rotation_degrees = 36.5
	$arm_left.position = Vector2(-500, 150)
	$arm_right.position = Vector2(500, 150)
	$arm_left.rotation_degrees = 62.5
	$arm_right.rotation_degrees = -62.5

func _physics_process(delta):
	direction = (get_node("../player").global_position - global_position + Vector2(0, -500)).normalized()
	var desired_velocity = direction * speed
	var steering = (desired_velocity - velocity) * delta * 7.5
	velocity += steering
	move_and_slide()
