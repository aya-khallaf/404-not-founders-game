extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TileMap.scale = Vector2(1., 1.)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func blue(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://play.tscn")


func space(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://basic_scene.tscn")


func red(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://red.tscn")
