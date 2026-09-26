extends Node2D
## Doodle-jump tree climb: bounce up break-once platforms, dodge falling
## branches, win after `target_jumps` bounces.

@export var target_jumps := 30
@export var win_scene_path := "res://red.tscn"
@export var level_half_width := 320.0
@export var platform_spacing_min := 100.0
@export var platform_spacing_max := 150.0
@export var extra_platforms := 25
@export var easy_start_jumps := 8
@export var easy_x_step := 110.0
@export var normal_x_step := 170.0
@export var branch_start_jump := 6
@export var branch_interval := 2.6
@export var branch_min_interval := 1.0
@export var branch_fall_speed := 280.0
@export var branch_damage := 15

const PlatformScene := preload("res://platform.tscn")
const BranchScene := preload("res://branch.tscn")
const TrunkTexture := preload("res://spritepaint 20.png")
const TRUNK_SCALE := 3.0

var _jumps := 0
var _game_over := false

@onready var _player: DoodlePlayer = $DoodlePlayer
@onready var _camera: Camera2D = $Camera2D
@onready var _platforms: Node2D = $Platforms
@onready var _branches: Node2D = $Branches
@onready var _trunk: Polygon2D = $TrunkBackground/Trunk
@onready var _knots: Node2D = $TrunkBackground/Knots
@onready var _jumps_label: Label = $CanvasLayer/HUDPanel/Margin/Rows/JumpsLabel
@onready var _health_bar: ProgressBar = $CanvasLayer/HUDPanel/Margin/Rows/HullRow/HealthBar
@onready var _message_label: Label = $CanvasLayer/MessageLabel
@onready var _branch_timer: Timer = $BranchTimer
@onready var _win_sound: AudioStreamPlayer = $WinSound

func _ready() -> void:
	randomize()
	_build_trunk()
	_build_platforms()
	_player.jumped.connect(_on_player_jumped)
	_player.health_changed.connect(_on_player_health_changed)
	_player.died.connect(_on_player_died)
	# Branches stay out of the easy opening so the player learns to bounce
	# first; the timer starts once they reach `branch_start_jump`.
	_branch_timer.wait_time = branch_interval
	_branch_timer.timeout.connect(_on_branch_timer_timeout)
	_camera.position = _player.global_position + Vector2(0, -120)
	_update_jumps_label()
	_health_bar.max_value = _player.max_health
	_health_bar.value = _player.current_health
	_message_label.visible = false

func _process(_delta: float) -> void:
	if _game_over:
		return
	# Camera only moves up, never down (classic doodle feel).
	if _player.global_position.y - 120.0 < _camera.position.y:
		_camera.position.y = _player.global_position.y - 120.0
	_camera.position.x = 0.0
	# Fell below view -> lose.
	if _player.global_position.y > _camera.position.y + 500.0:
		_game_over_by_fall()
		return
	# Clean up branches far below the camera.
	for branch in _branches.get_children():
		if branch.global_position.y > _camera.position.y + 700.0:
			branch.queue_free()

func _on_player_jumped() -> void:
	if _game_over:
		return
	_jumps += 1
	_update_jumps_label()
	if _jumps == branch_start_jump:
		_branch_timer.start()
	if _jumps >= target_jumps:
		_win()

func _on_player_health_changed(current: int, maximum: int) -> void:
	_health_bar.max_value = maximum
	_health_bar.value = current

func _on_player_died() -> void:
	if _game_over:
		return
	_game_over = true
	_branch_timer.stop()
	_message_label.text = "HULL BREACHED\nJUMPS %02d/%02d - RETRYING" % [_jumps, target_jumps]
	_message_label.visible = true
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()

func _game_over_by_fall() -> void:
	_game_over = true
	_branch_timer.stop()
	_message_label.text = "SIGNAL LOST - YOU FELL\nJUMPS %02d/%02d - RETRYING" % [_jumps, target_jumps]
	_message_label.visible = true
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()

func _win() -> void:
	_game_over = true
	_branch_timer.stop()
	_message_label.text = "ASCENT COMPLETE - %d JUMPS" % [_jumps]
	_message_label.visible = true
	_win_sound.play()
	await get_tree().create_timer(1.2).timeout
	if win_scene_path != "" and ResourceLoader.exists(win_scene_path):
		get_tree().change_scene_to_file(win_scene_path)

func _update_jumps_label() -> void:
	_jumps_label.text = "JUMPS %02d/%02d" % [_jumps, target_jumps]

func _build_trunk() -> void:
	# Artist's trunk segment tiled end-to-end, no stretch. The polygon is
	# hidden; these sprites ARE the background. Non-collidable visuals.
	_trunk.visible = false
	var total_height := float(target_jumps + extra_platforms) * platform_spacing_max + 2000.0
	var top_y := -total_height
	var tile_h := float(TrunkTexture.get_height()) * TRUNK_SCALE
	if tile_h <= 0.0:
		tile_h = 184.0
	var y := 900.0
	while y > top_y:
		var tile := Sprite2D.new()
		tile.texture = TrunkTexture
		tile.scale = Vector2(TRUNK_SCALE, TRUNK_SCALE)
		tile.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		tile.position = Vector2(0, y - tile_h * 0.5)
		_knots.add_child(tile)
		y -= tile_h

func _build_platforms() -> void:
	# Row-based like classic doodle: one platform per row, each row one
	# reachable hop above the last. Early rows stay near-center.
	var start_platform := _make_platform(Vector2(0, 120), true)
	_platforms.add_child(start_platform)
	var y := 0.0
	var prev_x := 0.0
	var count := target_jumps + extra_platforms
	for i in count:
		var easy := i < easy_start_jumps
		if easy:
			y -= randf_range(90.0, 120.0)
		else:
			y -= randf_range(platform_spacing_min, platform_spacing_max)
		var step := easy_x_step if easy else normal_x_step
		var x := clampf(prev_x + randf_range(-step, step), -level_half_width + 70.0, level_half_width - 70.0)
		if i < 3:
			x = clampf(x * 0.4, -90.0, 90.0)
		_platforms.add_child(_make_platform(Vector2(x, y)))
		prev_x = x
	# Safety platform high above the win height, also permanent.
	_platforms.add_child(_make_platform(Vector2(0, y - 120.0), true))

func _make_platform(pos: Vector2, permanent := false) -> StaticBody2D:
	var platform := PlatformScene.instantiate() as DoodlePlatform
	platform.position = pos
	platform.permanent = permanent
	return platform

func _on_branch_timer_timeout() -> void:
	if _game_over:
		return
	var branch := BranchScene.instantiate() as FallingBranch
	branch.fall_speed = branch_fall_speed
	branch.damage = branch_damage
	var x := randf_range(-level_half_width, level_half_width)
	branch.position = Vector2(x, _camera.position.y - 550.0)
	_branches.add_child(branch)
	# Ramp pressure with height, like the reference doodle game.
	_branch_timer.wait_time = maxf(branch_min_interval, branch_interval - float(_jumps) * 0.05)
