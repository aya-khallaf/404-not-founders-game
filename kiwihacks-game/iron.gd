extends Area2D
class_name IronSlab
## Iron pickup: drifts to the ship when close, +1 iron on touch.

@export var magnet_range := 150.0
@export var magnet_speed := 260.0
@export var value := 1

const ART_SCALE := 2.0
# Measured alpha bbox of spritepaint 28.png on its 92x92 canvas.
const ART_OFFSET := Vector2(12.5, 7.5)
const HITBOX := Vector2(42, 50)

var _taken := false
@onready var _art: Sprite2D = $Art
@onready var _collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group("iron")
	body_entered.connect(_on_body_entered)
	_art.position = ART_OFFSET
	if randf() < 0.5:
		_art.flip_h = true
		_art.position.x = -_art.position.x
	_collision.shape = _collision.shape.duplicate() as RectangleShape2D
	_collision.shape.size = HITBOX

func _physics_process(delta: float) -> void:
	var ship := Global.player_node as Node2D
	if ship == null or not is_instance_valid(ship):
		return
	var to_ship := ship.global_position - global_position
	if to_ship.length() < magnet_range:
		position += to_ship.normalized() * magnet_speed * delta

func _on_body_entered(body: Node2D) -> void:
	if _taken:
		return
	if body == Global.player_node:
		_taken = true
		var room := get_tree().current_scene
		if room != null and room.has_method("add_iron"):
			room.add_iron(value)
		queue_free()
