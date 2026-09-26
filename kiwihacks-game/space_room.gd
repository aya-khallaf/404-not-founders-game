extends Node2D
## Space room director for basic_scene: zombie-apocalypse waves from all
## directions. Stars drop 3-5 iron, rocks 1-2. Escape at 50 iron.

@export var iron_goal := 50
@export var spawn_ring := 650.0
@export var breather := 3.0
@export var nebula_scale := 4.0
@export var roam_half := Vector2(1600, 1200)
@export var roam_center := Vector2(300, -200)

const RockScene := preload("res://asteroid.tscn")
const StarScene := preload("res://star_enemy.tscn")
const ThiefScene := preload("res://thief.tscn")
const BgTexture := preload("res://spritepaint 50.png")

var _wave := 0
var _iron := 0
var _queue: Array = []
var _spawn_cd := 0.0
var _rest_cd := 0.0
var _won := false
var _last_count := -1
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
	_clamp_ship()
	var left := get_tree().get_nodes_in_group("foe").size()
	if left != _last_count:
		_update_hud(left)
	if not _queue.is_empty():
		_spawn_cd -= delta
		if _spawn_cd <= 0.0:
			_spawn_cd = 0.4
			_spawn_next()
		return
	if left == 0:
		_rest_cd -= delta
		if _rest_cd <= 0.0:
			_rest_cd = breather
			_start_wave(_wave + 1)

func _clamp_ship() -> void:
	# Soft walls: the roam area matches the backdrop, no physics needed.
	var ship := Global.player_node as Node2D
	if ship == null or not is_instance_valid(ship):
		return
	ship.global_position.x = clampf(ship.global_position.x, roam_center.x - roam_half.x, roam_center.x + roam_half.x)
	ship.global_position.y = clampf(ship.global_position.y, roam_center.y - roam_half.y, roam_center.y + roam_half.y)

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
	for i in mini(maxi(n - 1, 0), 3):
		_queue.append({"kind": "thief"})
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
	elif spec["kind"] == "thief":
		var thief := ThiefScene.instantiate() as IronThief
		thief.position = pos
		add_child(thief)
	else:
		var rock := RockScene.instantiate() as SpaceRock
		rock.position = pos
		if spec["kind"] == "fast":
			rock.hp = 1
			rock.drift_speed = 320.0 * randf_range(0.85, 1.2)
			rock.art_scale = 2.0
		else:
			rock.hp = 3
			rock.drift_speed = 90.0 * randf_range(0.85, 1.2)
			rock.art_scale = 3.0
		add_child(rock)
	_update_hud()

func steal_iron(max_amount: int) -> int:
	# Called by thieves: hands over carried iron, never below zero.
	var taken := mini(maxi(_iron, 0), max_amount)
	_iron -= taken
	_update_hud()
	return taken

func _win() -> void:
	_won = true
	_victory.play()
	_label.text = "50 IRON - SHIP REPAIRED - ESCAPED!"
	await get_tree().create_timer(3.5).timeout
	get_tree().reload_current_scene()

func _update_hud(left: int = -1) -> void:
	if left < 0:
		left = get_tree().get_nodes_in_group("foe").size()
	_last_count = left
	if _queue.is_empty() and left == 0 and _wave > 0:
		_label.text = "WAVE %d CLEAR - IRON %d/%d" % [_wave, _iron, iron_goal]
	else:
		_label.text = "WAVE %d - FOES %d - IRON %d/%d" % [_wave, left + _queue.size(), _iron, iron_goal]

func _tile_background() -> void:
	# Infinite scrolling backdrop, no physics: a slow nebula wash plus a
	# faster star layer, both mirrored so there are never edges or seams.
	var bg := ParallaxBackground.new()
	bg.name = "Backdrop"
	add_child(bg)
	var w := float(BgTexture.get_width()) * nebula_scale
	var h := float(BgTexture.get_height()) * nebula_scale
	if w > 0.0:
		var nebula := ParallaxLayer.new()
		nebula.motion_scale = Vector2(0.25, 0.25)
		nebula.motion_mirroring = Vector2(w, h)
		bg.add_child(nebula)
		var wash := Sprite2D.new()
		wash.texture = BgTexture
		wash.scale = Vector2(nebula_scale, nebula_scale)
		wash.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		wash.centered = true
		nebula.add_child(wash)
	var stars := ParallaxLayer.new()
	stars.motion_scale = Vector2(0.6, 0.6)
	stars.motion_mirroring = Vector2(1024, 1024)
	bg.add_child(stars)
	for i in 140:
		var dot := Polygon2D.new()
		var s := randf_range(1.0, 3.0)
		var p := Vector2(randf_range(-512, 512), randf_range(-512, 512))
		dot.polygon = PackedVector2Array([p, p + Vector2(s, 0), p + Vector2(s, s), p + Vector2(0, s)])
		var b := randf_range(0.4, 1.0)
		dot.color = Color(b, b, b * randf_range(0.9, 1.0), 1)
		stars.add_child(dot)

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
