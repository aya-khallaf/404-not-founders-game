extends Area2D
class_name FallingBranch

@export var fall_speed := 280.0
@export var damage := 15
@export var spin := 12.0
@export var drift := 20.0

# Artist sprites as-is, uniform scale, no stretch. Hitbox = exact drawn
# pixels: measured alpha bboxes on the 92x92 spritepaint canvases.
# Set 0 = blue twigs (24-26), set 1 = red cactus (40).
const ART_SCALE := 4.0
const CANVAS_CENTER := Vector2(46, 46)
const SETS := {
	0: [
		{"tex": preload("res://spritepaint 24.png"), "min": Vector2(20, 23), "size": Vector2(30, 26)},
		{"tex": preload("res://spritepaint 25.png"), "min": Vector2(19, 23), "size": Vector2(31, 26)},
		{"tex": preload("res://spritepaint 26.png"), "min": Vector2(41, 27), "size": Vector2(33, 26)},
	],
	1: [
		{"tex": preload("res://spritepaint 40.png"), "min": Vector2(30, 22), "size": Vector2(28, 36)},
	],
}
@export var art_set := 0

var _t := 0.0
var _drift_dir := 1.0
@onready var _art: Sprite2D = $Art
@onready var _collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group("branch")
	body_entered.connect(_on_body_entered)
	var set: Array = SETS.get(art_set, SETS[0])
	var variant: Dictionary = set[randi() % set.size()]
	var px_size: Vector2 = variant["size"] * ART_SCALE
	var center: Vector2 = variant["min"] + variant["size"] * 0.5
	_art.texture = variant["tex"]
	_art.position = (CANVAS_CENTER - center) * ART_SCALE
	if randf() < 0.5:
		_art.flip_h = true
		_art.position.x = -_art.position.x
	_collision.shape = _collision.shape.duplicate() as RectangleShape2D
	_collision.shape.size = px_size
	rotation = randf_range(-0.35, 0.35)
	_drift_dir = -1.0 if randf() < 0.5 else 1.0

func _physics_process(delta: float) -> void:
	_t += delta
	position.y += fall_speed * delta
	position.x += _drift_dir * drift * delta
	rotation += deg_to_rad(spin) * delta * _drift_dir
	if rotation > 0.5:
		_drift_dir = -1.0
	elif rotation < -0.5:
		_drift_dir = 1.0

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
