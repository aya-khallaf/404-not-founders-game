extends Area2D
class_name IronThief
## Gremlin that steals carried iron and flees. Kill it to drop everything
## it holds plus one extra. No hull damage, just robbery.

@export var speed := 330.0
@export var flee_speed := 380.0
@export var hp := 1
@export var steal_amount := 5

const ART_SCALE := 2.0
# Measured alpha bbox of spritepaint 37.png (x24,y23 21x31).
const ART_OFFSET := Vector2(23, 15)
const HITBOX := Vector2(42, 62)
const IronScene := preload("res://iron.tscn")

var carried := 0
var _fleeing := false
var _cooldown := 0.0
@onready var _art: Sprite2D = $Art
@onready var _collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group("foe")
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	speed *= randf_range(0.9, 1.15)
	_art.position = ART_OFFSET
	if randf() < 0.5:
		_art.flip_h = true
		_art.position.x = -_art.position.x
	_collision.shape = _collision.shape.duplicate() as RectangleShape2D
	_collision.shape.size = HITBOX

func _physics_process(delta: float) -> void:
	_cooldown = maxf(0.0, _cooldown - delta)
	var ship := Global.player_node as Node2D
	if ship == null or not is_instance_valid(ship):
		return
	var to_me := global_position - ship.global_position
	if to_me.length() > 1500.0:
		queue_free()
		return
	if _fleeing:
		if to_me.length() > 1.0:
			position += to_me.normalized() * flee_speed * delta
	else:
		if to_me.length() > 70.0:
			position -= to_me.normalized() * speed * delta

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Weapon"):
		return
	if area.is_in_group("bolt"):
		hp -= 1
		if hp <= 0:
			_drop_all()
			queue_free()

func _on_body_entered(body: Node2D) -> void:
	if _fleeing or _cooldown > 0.0:
		return
	if body == Global.player_node:
		_cooldown = 1.0
		var room := get_tree().current_scene
		if room != null and room.has_method("steal_iron"):
			carried = room.steal_iron(steal_amount)
		_fleeing = true

func _drop_all() -> void:
	var scene := get_tree().current_scene
	for i in carried + 1:
		var slab := IronScene.instantiate() as IronSlab
		slab.position = global_position + Vector2(randf_range(-40, 40), randf_range(-40, 40))
		scene.add_child(slab)
