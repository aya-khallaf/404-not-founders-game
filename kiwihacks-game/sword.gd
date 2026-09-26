extends Area2D

func _process(delta: float) -> void:
	if Input.is_action_pressed("attack"):
		$Spritepaint27.visible = true
		rotation+=0.3
	else:
		$Spritepaint27.visible = false
