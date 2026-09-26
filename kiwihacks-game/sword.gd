extends Area2D

func _process(delta: float) -> void:
	# No sword while flying the ship; the gun takes over.
	var ship := get_parent()
	if ship != null and ship.get("in_spaceship"):
		$Spritepaint27.visible = false
		return
	if Input.is_action_pressed("attack"):
		$Spritepaint27.visible = true
		rotation+=0.3
	else:
		$Spritepaint27.visible = false
