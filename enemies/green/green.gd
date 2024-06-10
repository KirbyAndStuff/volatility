extends CharacterBody2D

var green_death := preload("res://enemies/green/green_death.tscn")
var green_hurt := preload("res://enemies/green/green_hurt.tscn")

var health = 3
var guarded = false

func _ready():
	var effect := green_hurt.instantiate()
	effect.position = position
	get_parent().call_deferred("add_child", effect)

func _process(_delta):
	if health < 1:
		var effect := green_death.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		effect.die(1)
		queue_free()
	if $GunTimer.is_stopped():
		$green_bulletsfx.play()
		var bullet_scene = preload("res://enemies/green/green_bullet.tscn")
		var shot = bullet_scene.instantiate()
		get_parent().add_child(shot)
		shot.shoot(global_position, get_node("../player").global_position)
		$GunTimer.start()

func _on_playerdeath_area_entered(area):
	if area.is_in_group("player_attack") and guarded == false:
		var effect := green_hurt.instantiate()
		effect.position = position
		get_parent().add_child(effect)
		effect.die(0.5)
		health -= area.get_parent().damage
