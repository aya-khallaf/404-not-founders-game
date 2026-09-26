extends Node2D
class_name ShipGun
## Gun that replaces the sword while the player is in the spaceship.
## Hold SPACE (ui_accept) to fire toward movement, else straight up.

@export var cooldown := 0.22
@export var muzzle := 34.0

const LaserScene := preload("res://laser.tscn")

var _cd := 0.0
var _aim := Vector2.UP

@onready var _barrel: Polygon2D = $Barrel
@onready var _ship: CharacterBody2D = get_parent()

func _process(delta: float) -> void:
	var in_ship: bool = _ship.get("in_spaceship")
	visible = in_ship
	if not in_ship:
		return
	var move := Input.get_vector("left", "right", "up", "down")
	if move.length() > 0.2:
		_aim = move.normalized()
	_barrel.rotation = _aim.angle() + PI * 0.5
	_cd -= delta
	if Input.is_action_pressed("ui_accept") and _cd <= 0.0:
		_cd = cooldown
		var laser := LaserScene.instantiate() as LaserBolt
		laser.direction = _aim
		laser.shooter = _ship
		laser.global_position = global_position + _aim * muzzle
		get_tree().current_scene.add_child(laser)
