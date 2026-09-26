extends Node2D
## Space room director for basic_scene: zombie-apocalypse waves from all
## directions. Stars drop 3-5 iron, rocks 1-2. Escape at 50 iron.

@export var iron_goal := 50
@export var spawn_ring := 650.0
@export var breather := 3.0
@export var bg_scale := 2.0

const RockScene := preload("res://asteroid.tscn")
const StarScene := preload("res://star_enemy.tscn")
const BgTexture := preload("res://spritepaint 50.png")

var _wave := 0
var _iron := 0
var _queue: Array = []
var _spawn_cd := 0.0
var _rest_cd := 0.0
var _won := false
var _label: Label
var _bgm: AudioStreamPlayer
var _victory: AudioStreamPlayer

func _ready() -> void:
	randomize()
	_tile_background()
	_start_audio()
	_build_hud()
	_rest_cd = 1.0

func _process(delta: float) -> void:
	if _won:
		return
	if not _queue.is_empty():
		_spawn_cd -= delta
		if _spawn_cd <= 0.0:
			_spawn_cd = 0.4
			_spawn_next()
		return
	if get_tree().get_nodes_in_group("foe").is_empty():
		_rest_cd -= delta
		if _rest_cd <= 0.0:
			_start_wave(_wave + 1)

func add_iron(value: int) -> void:
	if _won:
		return
	_iron += value
	_update_hud()
	if _iron >= iron_goal:
		_win()

func _start_wave(n: int) -> void:
	_wave = n
	_queue.clear()
	for i in 2 + n:
		_queue.append({"kind": "slow"})
	for i in 1 + n:
		_queue.append({"kind": "fast"})
	for i in mini(n, 4):
		_queue.append({"kind": "star"})
	_queue.shuffle()
	_spawn_cd = 0.0
	_update_hud()

func _spawn_next() -> void:
	var spec: Dictionary = _queue.pop_back()
	var ship := Global.player_node as Node2D
	var center := Vector2(300, -200)
	if ship != null and is_instance_valid(ship):
		center = ship.global_position
	var angle := randf() * TAU
	var pos := center + Vector2(cos(angle), sin(angle)) * spawn_ring
	if spec["kind"] == "star":
		var star := StarScene.instantiate() as StarEnemy
		star.position = pos
		add_child(star)
	else:
		var rock := RockScene.instantiate() as SpaceRock
		rock.position = pos
		if spec["kind"] == "fast":
			rock.hp = 1
			rock.drift_speed = 320.0
			rock.art_scale = 2.0
		else:
			rock.hp = 3
			rock.drift_speed = 90.0
			rock.art_scale = 3.0
		add_child(rock)
	_update_hud()

func _win() -> void:
	_won = true
	_victory.play()
	_label.text = "50 IRON - SHIP REPAIRED - ESCAPED!"
	await get_tree().create_timer(3.5).timeout
	get_tree().reload_current_scene()

func _update_hud() -> void:
	var left := get_tree().get_nodes_in_group("foe").size()
	if _queue.is_empty() and left == 0 and _wave > 0:
		_label.text = "WAVE %d CLEAR - IRON %d/%d" % [_wave, _iron, iron_goal]
	else:
		_label.text = "WAVE %d - FOES %d - IRON %d/%d" % [_wave, left + _queue.size(), _iron, iron_goal]

func _tile_background() -> void:
	var w := float(BgTexture.get_width()) * bg_scale
	var h := float(BgTexture.get_height()) * bg_scale
	if w <= 0.0:
		return
	var tiles := Node2D.new()
	tiles.name = "StarTiles"
	tiles.z_index = -90
	add_child(tiles)
	var x := 300.0 - 1600.0
	while x < 300.0 + 1600.0:
		var y := -200.0 - 1200.0
		while y < -200.0 + 1200.0:
			var tile := Sprite2D.new()
			tile.texture = BgTexture
			tile.scale = Vector2(bg_scale, bg_scale)
			tile.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			tile.centered = true
			tile.position = Vector2(x + w * 0.5, y + h * 0.5)
			tiles.add_child(tile)
			y += h
		x += w

func _start_audio() -> void:
	_bgm = AudioStreamPlayer.new()
	_bgm.stream = load("res://space_ambient.mp3")
	if _bgm.stream is AudioStreamMP3:
		(_bgm.stream as AudioStreamMP3).loop = true
	_bgm.volume_db = -16.0
	add_child(_bgm)
	_bgm.play()
	_victory = AudioStreamPlayer.new()
	_victory.stream = load("res://victory.mp3")
	_victory.volume_db = -6.0
	add_child(_victory)

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	_label = Label.new()
	var mono := load("res://VCR_OSD_MONO_1.001.ttf") as Font
	if mono:
		_label.add_theme_font_override("font", mono)
	_label.add_theme_font_size_override("font_size", 24)
	_label.add_theme_color_override("font_color", Color(0.7, 0.95, 1, 1))
	_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	_label.add_theme_constant_override("outline_size", 6)
	_label.offset_left = 16
	_label.offset_top = 12
	_label.offset_right = 700
	_label.offset_bottom = 52
	layer.add_child(_label)
