extends CharacterBody2D

var damage_took = 0

func _on_player_death_area_entered(area):
	if area.is_in_group("deal 1 damage"):
		damage_took += 1
		$Label.text = "Single damage: 1  Total damage : " + str(damage_took)
	if area.is_in_group("deal 2 damage"):
		damage_took += 2
		$Label.text = "Single damage: 2  Total damage: " + str(damage_took)
	if area.is_in_group("deal 3 damage"):
		damage_took += 3
		$Label.text = "Single damage: 3  total damage: " + str(damage_took)
