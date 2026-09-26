extends Node2D
## Space room rules for basic_scene: clear all 8 asteroid blobs.
## Kill counter HUD; sector clear message, then the room resets.

var _total := 0
var _over := false
var _label: Label

func _ready() -> void:
	_total = get_tree().get_nodes_in_group("foe").size()
	var layer := CanvasLayer.new()
	add_child(layer)
	_label = Label.new()
	var mono := load("res://VCR_OSD_MONO_1.001.ttf") as Font
	if mono:
		_label.add_theme_font_override("font", mono)
	_label.add_theme_font_size_override("font_size", 26)
	_label.add_theme_color_override("font_color", Color(0.7, 0.95, 1, 1))
	_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	_label.add_theme_constant_override("outline_size", 6)
	_label.offset_left = 16
	_label.offset_top = 12
	_label.offset_right = 500
	_label.offset_bottom = 52
	layer.add_child(_label)
	_update_hud()

func _process(_delta: float) -> void:
	if _over:
		return
	var left := get_tree().get_nodes_in_group("foe").size()
	_update_hud(left)
	if left <= 0:
		_over = true
		_label.text = "SECTOR CLEAR - RESETTING..."
		await get_tree().create_timer(2.5).timeout
		get_tree().reload_current_scene()

func _update_hud(left: int = -1) -> void:
	if left < 0:
		left = get_tree().get_nodes_in_group("foe").size()
	_label.text = "ASTEROIDS %d/%d - WASD FLY - SPACE FIRE" % [_total - left, _total]
