extends Area2D
class_name SpaceRock
## Drifting asteroid. Slow rocks take 3 laser hits, fast ones 1.
## Touch hurts the hull. Death drops 1-2 iron slabs.

@export var hp := 3
@export var drift_speed := 90.0
@export var touch_damage := 15
@export var art_scale := 3.0
@export var art_texture: Texture2D
# Measured alpha bbox of spritepaint 8 (x17,y10 24x21): centers the rock.
@export var art_offset := Vector2(17, 25.5)

const IronScene := preload("res://iron.tscn")

var _dir := Vector2.RIGHT
var _spin := 0.0
var _cooldown := 0.0
@onready var _art: Sprite2D = $Art
@onready var _collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group("foe")
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	if art_texture:
		_art.texture = art_texture
	_art.scale = Vector2(art_scale, art_scale)
	_art.position = art_offset * art_scale
	if randf() < 0.5:
		_art.flip_h = true
		_art.position.x = -_art.position.x
	# Hitbox matches the drawn rock exactly (bbox * scale).
	var content := Vector2(24, 21)
	_collision.shape = _collision.shape.duplicate() as RectangleShape2D
	_collision.shape.size = content * art_scale
	# Drift toward the ship (with spread) so rocks come AT you from all
	# directions instead of wandering into the void and stalling waves.
	var ship := Global.player_node as Node2D
	if ship != null and is_instance_valid(ship):
		var to_ship := (ship.global_position - global_position).normalized()
		_dir = to_ship.rotated(randf_range(-1.1, 1.1))
		if _dir.length() < 0.5:
			_dir = Vector2.RIGHT.rotated(randf() * TAU)
	else:
		_dir = Vector2.RIGHT.rotated(randf() * TAU)
	_spin = randf_range(-1.2, 1.2)

func _physics_process(delta: float) -> void:
	_cooldown = maxf(0.0, _cooldown - delta)
	position += _dir * drift_speed * delta
	rotation += _spin * delta
	# Cull escapees so the wave can always complete.
	var ship := Global.player_node as Node2D
	if ship != null and is_instance_valid(ship):
		if global_position.distance_to(ship.global_position) > 1500.0:
			queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Weapon"):
		return
	if area.is_in_group("bolt"):
		_take_hit(1)

func _take_hit(amount: int) -> void:
	hp -= amount
	_flash()
	if hp <= 0:
		_drop_iron(randi_range(1, 2))
		queue_free()

func _drop_iron(count: int) -> void:
	var scene := get_tree().current_scene
	for i in count:
		var slab := IronScene.instantiate() as IronSlab
		slab.position = global_position + Vector2(randf_range(-30, 30), randf_range(-30, 30))
		scene.add_child(slab)

func _on_body_entered(body: Node2D) -> void:
	if body == Global.player_node and _cooldown <= 0.0:
		_cooldown = 1.0
		body.set("health", maxi(0, int(body.get("health")) - touch_damage))

func _flash() -> void:
	var tween := create_tween()
	tween.tween_property(_art, "modulate", Color(2, 2, 2, 1), 0.05)
	tween.tween_property(_art, "modulate", Color(1, 1, 1, 1), 0.1)
