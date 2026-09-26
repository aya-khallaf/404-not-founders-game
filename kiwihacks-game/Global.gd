extends Node
var player_node = null
var red = false
var blue = false
var space = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if blue and space and red:
		get_tree().change_scene_to_file("res://control-spaceship.tscn")
