extends Area2D
class_name LaserBolt

@export var speed := 900.0
@export var life := 1.2

var direction := Vector2.UP
var shooter: Node2D = null
var _age := 0.0

func _ready() -> void:
	add_to_group("bolt")
	rotation = direction.angle() + PI * 0.5
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	_age += delta
	if _age >= life:
		queue_free()
		return
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body == shooter:
		return
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	# Pass through the ship's own sword; foe hitboxes damage themselves.
	if area.is_in_group("Weapon"):
		return
	if shooter != null and area.get_parent() == shooter:
		return
	queue_free()
