extends Area2D
class_name StarEnemy
## Star chaser: hunts the ship, takes 5 laser hits, drops 3-5 iron.

@export var hp := 5
@export var speed := 220.0
@export var touch_damage := 10

const ART_SCALE := 2.0
# Measured alpha bbox of spritepaint 38.png (x26,y28 42x41).
const ART_OFFSET := Vector2(-1, -2.5)
const HITBOX := Vector2(84, 82)
const IronScene := preload("res://iron.tscn")

var _cooldown := 0.0
@onready var _art: Sprite2D = $Art
@onready var _collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group("foe")
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	_art.position = ART_OFFSET
	if randf() < 0.5:
		_art.flip_h = true
		_art.position.x = -_art.position.x
	_collision.shape = _collision.shape.duplicate() as RectangleShape2D
	_collision.shape.size = HITBOX

func _physics_process(delta: float) -> void:
	_cooldown = maxf(0.0, _cooldown - delta)
	var ship := Global.player_node as Node2D
	if ship != null and is_instance_valid(ship):
		var dir := ship.global_position - global_position
		if dir.length() > 1500.0:
			queue_free()
			return
		if dir.length() > 1.0:
			position += dir.normalized() * speed * delta

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Weapon"):
		return
	if area.is_in_group("bolt"):
		hp -= 1
		_flash()
		if hp <= 0:
			for i in randi_range(3, 5):
				var slab := IronScene.instantiate() as IronSlab
				slab.position = global_position + Vector2(randf_range(-40, 40), randf_range(-40, 40))
				get_tree().current_scene.add_child(slab)
			queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body == Global.player_node and _cooldown <= 0.0:
		_cooldown = 1.0
		body.set("health", maxi(0, int(body.get("health")) - touch_damage))

func _flash() -> void:
	var tween := create_tween()
	tween.tween_property(_art, "modulate", Color(2, 2, 2, 1), 0.05)
	tween.tween_property(_art, "modulate", Color(1, 1, 1, 1), 0.1)
