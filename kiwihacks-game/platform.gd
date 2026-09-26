extends StaticBody2D
class_name DoodlePlatform

## How long the platform holds after the player lands before it breaks.
## Manual jump: land, then hop off before it gives way.
@export var break_delay := 0.9
## Starter / safety platforms never crumble.
@export var permanent := false

# Artist sprites as-is, uniform scale, no stretch. Hitbox = exact drawn
# pixels: measured alpha bboxes on the 92x92 spritepaint canvases.
# Set 0 = blue twigs (21-23), set 1 = red twigs (39).
const ART_SCALE := 4.0
const CANVAS_CENTER := Vector2(46, 46)
const SETS := {
	0: [
		{"tex": preload("res://spritepaint 21.png"), "min": Vector2(56, 44), "size": Vector2(19, 10)},
		{"tex": preload("res://spritepaint 22.png"), "min": Vector2(49, 45), "size": Vector2(22, 8)},
		{"tex": preload("res://spritepaint 23.png"), "min": Vector2(57, 46), "size": Vector2(19, 12)},
	],
	1: [
		{"tex": preload("res://spritepaint 39.png"), "min": Vector2(28, 31), "size": Vector2(36, 27)},
	],
}
@export var art_set := 0

var _triggered := false
@onready var _art: Sprite2D = $Art
@onready var _collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group("platform")
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

func touch() -> void:
	if permanent or _triggered:
		return
	_triggered = true
	_break_after_delay()

func bounce_platform() -> void:
	touch()

func _break_after_delay() -> void:
	# Small shake so the player reads that it is about to break.
	var start_x := position.x
	var shake := create_tween()
	shake.tween_property(self, "position:x", start_x - 5.0, 0.07)
	shake.tween_property(self, "position:x", start_x + 5.0, 0.07)
	shake.tween_property(self, "position:x", start_x - 4.0, 0.07)
	shake.tween_property(self, "position:x", start_x, 0.07)
	await shake.finished
	var rest := break_delay - 0.28
	if rest > 0.0:
		await get_tree().create_timer(rest).timeout
	# Drop through, then fall + fade.
	_collision.set_deferred("disabled", true)
	var fall := create_tween()
	fall.set_parallel(true)
	fall.tween_property(self, "position:y", position.y + 600.0, 0.9).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	fall.tween_property(self, "modulate:a", 0.0, 0.9)
	await fall.finished
	queue_free()
