extends CharacterBody2D

var damage_took = 0

func _on_player_death_area_entered(area):
	if area.is_in_group("player_attack"):
		damage_took += area.get_parent().damage
		$Label.text = "Single damage: " + str(area.get_parent().damage) + "  Total damage: " + str(damage_took)
