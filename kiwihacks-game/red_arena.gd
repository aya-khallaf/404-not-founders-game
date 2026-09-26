extends Node2D
class_name RedArena
## Survive 60s against LavaBlob floaters in the red world, then return.
## Instances the friends' red.tscn untouched and adds rules on top.

@export var survive_time := 60.0
@export var max_hp := 3
@export var spawn_start := 2.5
@export var spawn_end := 1.2
@export var max_floaters := 8

const FloaterScene := preload("res://floater.tscn")

var _time_left: float
var _hp: int
var _over := false
var _iframes := 0.0

@onready var _player: CharacterBody2D = $Red/CharacterBody2D
@onready var _foes: Node2D = $Floaters
@onready var _timer_label: Label = $CanvasLayer/TimerLabel
@onready var _hp_label: Label = $CanvasLayer/HpLabel
@onready var _message: Label = $CanvasLayer/MessageLabel
@onready var _spawn_timer: Timer = $SpawnTimer

func _ready() -> void:
	_time_left = survive_time
	_hp = max_hp
	_player.add_to_group("arena_player")
	_spawn_timer.wait_time = spawn_start
	_spawn_timer.timeout.connect(_spawn_floater)
	_spawn_timer.start()
	_update_hud()
	_message.visible = false

func _process(delta: float) -> void:
	if _over:
		return
	_iframes = maxf(0.0, _iframes - delta)
	_time_left -= delta
	if _time_left <= 0.0:
		_win()
		return
	_update_hud()

func register_touch(floater: Floater, body: Node2D) -> void:
	if _over or body != _player or _iframes > 0.0:
		return
	_hp -= 1
	_iframes = 1.0
	floater.queue_free()
	_flash_player()
	_update_hud()
	if _hp <= 0:
		_lose()

func _spawn_floater() -> void:
	if _over:
		return
	if _foes.get_child_count() >= max_floaters:
		return
	var progress := 1.0 - _time_left / survive_time
	var floater := FloaterScene.instantiate() as Floater
	floater.speed = lerpf(130.0, 200.0, progress)
	var angle := randf() * TAU
	floater.position = _player.global_position + Vector2(cos(angle), sin(angle)) * 520.0
	floater._player = _player
	_foes.add_child(floater)
	_spawn_timer.wait_time = lerpf(spawn_start, spawn_end, progress)

func _win() -> void:
	_over = true
	Global.red_done = true
	_spawn_timer.stop()
	_message.text = "SURVIVED - PORTAL CLEAR\nRETURNING..."
	_message.visible = true
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://hub.tscn")

func _lose() -> void:
	_over = true
	_spawn_timer.stop()
	_message.text = "HULL BREACHED - RETRYING"
	_message.visible = true
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()

func _update_hud() -> void:
	_timer_label.text = "SURVIVE %02d" % int(ceil(_time_left))
	var hearts := ""
	for i in max_hp:
		hearts += "[X]" if i < _hp else "[ ]"
	_hp_label.text = "HULL " + hearts

func _flash_player() -> void:
	var sprite := _player.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if sprite == null:
		return
	var tween := create_tween()
	for i in 4:
		tween.tween_property(sprite, "modulate:a", 0.25, 0.08)
		tween.tween_property(sprite, "modulate:a", 1.0, 0.08)
