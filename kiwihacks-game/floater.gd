extends Area2D
class_name Floater

@export var speed := 140.0

const ART_SCALE := 3.0
# Measured alpha bboxes on the 92x92 canvases: red lava (7), orange (37).
const VARIANTS := [
	{"tex": preload("res://spritepaint 7.png"), "min": Vector2(16, 20), "size": Vector2(17, 17)},
	{"tex": preload("res://spritepaint 37.png"), "min": Vector2(24, 23), "size": Vector2(21, 31)},
]

var _player: Node2D = null

@onready var _art: Sprite2D = $Art
@onready var _collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group("hazard")
	body_entered.connect(_on_body_entered)
	var variant: Dictionary = VARIANTS[randi() % VARIANTS.size()]
	var px_size: Vector2 = variant["size"] * ART_SCALE
	var center: Vector2 = variant["min"] + variant["size"] * 0.5
	_art.texture = variant["tex"]
	_art.position = (Vector2(46, 46) - center) * ART_SCALE
	if randf() < 0.5:
		_art.flip_h = true
		_art.position.x = -_art.position.x
	_collision.shape = _collision.shape.duplicate() as RectangleShape2D
	_collision.shape.size = px_size

func _physics_process(delta: float) -> void:
	if _player != null and is_instance_valid(_player):
		var dir := _player.global_position - global_position
		if dir.length() > 1.0:
			position += dir.normalized() * speed * delta

func _on_body_entered(body: Node2D) -> void:
	var arena := get_parent() as RedArena
	if arena:
		arena.register_touch(self, body)
