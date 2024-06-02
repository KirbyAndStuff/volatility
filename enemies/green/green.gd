extends CharacterBody2D

var green_death := preload("res://enemies/green/green_death.tscn")
var green_hurt := preload("res://enemies/green/green_hurt.tscn")

var green_health = 3

func _ready():
	#var delay = RandomNumberGenerator.new().randf_range(0, 0.25)
	#$GunTimer.wait_time = 0.25 + delay
	#$GunTimer.start()
	var effect := green_hurt.instantiate()
	effect.position = position
	get_parent().call_deferred("add_child", effect)

func _process(_delta):
	if green_health < 1:
		var effect := green_death.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		queue_free()
	if $GunTimer.is_stopped():
		#var delay = RandomNumberGenerator.new().randf_range(0, 0.25)
		$green_bulletsfx.play()
		var bullet_scene = preload("res://enemies/green/green_bullet.tscn")
		var shot = bullet_scene.instantiate()
		get_parent().add_child(shot)
		shot.shoot(global_position, get_node("../player").global_position)
		#$GunTimer.wait_time = 0.75 + delay
		$GunTimer.start()

func _on_playerdeath_area_entered(area):
	if area.is_in_group("player_attack"):
		var effect := green_hurt.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		green_health -= area.get_parent().damage
