extends Node2D
## Portal hub: walk into a swirl to enter a challenge. Returning sets
## Global flags; all three clear sends you home (ending).

@onready var _player: CharacterBody2D = $HubPlayer
@onready var _camera: Camera2D = $Camera2D
@onready var _board: Label = $CanvasLayer/BoardLabel

func _ready() -> void:
	randomize()
	_build_stars()
	_camera.position = _player.global_position
	_update_board()
	if Global.all_done():
		_board.text = "ALL PORTALS CLEAR - GOING HOME..."
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://ending.tscn")

func _process(_delta: float) -> void:
	_camera.position = _player.global_position

func _update_board() -> void:
	_board.text = "PORTALS %d/3 - BLUE:%s RED:%s ECHO:%s" % [
		Global.done_count(),
		"CLEAR" if Global.blue_done else "--",
		"CLEAR" if Global.red_done else "--",
		"CLEAR" if Global.echo_done else "--",
	]

func _build_stars() -> void:
	var stars := $Starfield as Node2D
	for i in 220:
		var dot := Polygon2D.new()
		var s := randf_range(1.0, 2.5)
		var p := Vector2(randf_range(-900, 900), randf_range(-550, 550))
		dot.polygon = PackedVector2Array([p, p + Vector2(s, 0), p + Vector2(s, s), p + Vector2(0, s)])
		var b := randf_range(0.35, 1.0)
		dot.color = Color(b, b, b * randf_range(0.9, 1.0), 1)
		stars.add_child(dot)
