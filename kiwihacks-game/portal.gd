extends Area2D
class_name HubPortal

## Scene to load on entry. Empty = locked decoration.
@export var target_scene := ""
## Short label shown above the portal.
@export var title := "PORTAL"
## Global flag name that marks this portal done (blue_done/red_done/echo_done).
@export var flag_name := ""
## Text shown when the portal is locked.
@export var locked_text := "LOCKED"
## Portal swirl art (blue 30 / purple 31 / red 32).
@export var art: Texture2D

@onready var _label: Label = $TitleLabel
@onready var _status: Label = $StatusLabel
@onready var _art: Sprite2D = $Art

func _ready() -> void:
	add_to_group("portal")
	body_entered.connect(_on_body_entered)
	if art:
		_art.texture = art
	_label.text = title
	_refresh()

func _refresh() -> void:
	if flag_name != "" and Global.get(flag_name):
		_status.text = "CLEAR"
		_status.modulate = Color(0.45, 0.95, 0.5, 1)
	elif target_scene == "":
		_status.text = locked_text
		_status.modulate = Color(1, 0.4, 0.4, 1)
	else:
		_status.text = "ENTER"
		_status.modulate = Color(0.9, 0.9, 0.9, 0.85)

func _on_body_entered(body: Node2D) -> void:
	if not body is CharacterBody2D:
		return
	if target_scene == "":
		return
	get_tree().change_scene_to_file(target_scene)
