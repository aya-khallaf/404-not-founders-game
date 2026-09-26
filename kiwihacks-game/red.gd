extends Node2D

var player_in = false

func _ready() -> void:
	$TileMap.scale = Vector2(2.5, 2.5)

func _process(delta: float) -> void:
	var completeted = true
	for child in get_children():
		if child.scene_file_path == "res://enemy.tscn":
			completeted = false
	if completeted:
		$AnimatedSprite2D.play("open")
		if player_in:
			get_tree().change_scene_to_file("res://hub world.tscn")
			Global.red = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == Global.player_node:
		player_in = true
