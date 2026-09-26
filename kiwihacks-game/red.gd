extends Node2D

func _ready() -> void:
	$TileMap.scale = Vector2(2.5, 2.5)

func _process(delta: float) -> void:
	var completeted = true
	for child in get_children():
		if child.scene_file_path == "res://enemy.tscn":
			completeted = false
	if completeted:
		$AnimatedSprite2D.play("open")
