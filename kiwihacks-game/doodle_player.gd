extends CharacterBody2D
class_name DoodlePlayer

signal jumped
signal health_changed(current: int, maximum: int)
signal died

@export var move_speed := 400.0
@export var jump_velocity := -850.0
@export var gravity := 1400.0
@export var max_health := 100
@export var wrap_half_width := 340.0
@export var coyote_time := 0.12
@export var jump_buffer := 0.15

var current_health: int
var _invincible := false
var _coyote := 0.0
var _buffer := 0.0
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _hurt_sound: AudioStreamPlayer = $HurtSound

func _ready() -> void:
	add_to_group("player")
	current_health = max_health
	if _sprite:
		_sprite.play("walk")
	health_changed.emit(current_health, max_health)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	var axis := Input.get_axis("left", "right")
	velocity.x = axis * move_speed
	# Manual jump with coyote time + input buffer for fair feel.
	if is_on_floor():
		_coyote = coyote_time
	else:
		_coyote -= delta
	if Input.is_action_just_pressed("up") or Input.is_action_just_pressed("ui_accept"):
		_buffer = jump_buffer
	else:
		_buffer -= delta
	# Jump cut: release early for a shorter hop.
	if (Input.is_action_just_released("up") or Input.is_action_just_released("ui_accept")) and velocity.y < -350.0:
		velocity.y *= 0.5
	move_and_slide()
	# Horizontal screen wrap.
	if global_position.x < -wrap_half_width:
		global_position.x = wrap_half_width
	elif global_position.x > wrap_half_width:
		global_position.x = -wrap_half_width
	if _buffer > 0.0 and (is_on_floor() or _coyote > 0.0):
		_do_jump()
	# Touching a platform starts its crumble timer; no auto-bounce.
	if is_on_floor():
		for i in get_slide_collision_count():
			var collision := get_slide_collision(i)
			if collision.get_normal().y > -0.7:
				continue
			var collider := collision.get_collider()
			if collider != null and collider.is_in_group("platform") and collider.has_method("touch"):
				collider.touch()

func _do_jump() -> void:
	_buffer = 0.0
	_coyote = 0.0
	velocity.y = jump_velocity
	jumped.emit()
	_squash()

func take_damage(amount: int) -> void:
	if _invincible:
		return
	current_health = maxi(0, current_health - amount)
	health_changed.emit(current_health, max_health)
	_hurt_sound.play()
	_flash()
	if current_health <= 0:
		died.emit()
		return
	_invincible = true
	await get_tree().create_timer(0.8).timeout
	_invincible = false

func _flash() -> void:
	if _sprite == null:
		return
	var tween := create_tween()
	tween.tween_property(_sprite, "modulate:a", 0.25, 0.08)
	tween.tween_property(_sprite, "modulate:a", 1.0, 0.08)
	tween.tween_property(_sprite, "modulate:a", 0.25, 0.08)
	tween.tween_property(_sprite, "modulate:a", 1.0, 0.08)

func _squash() -> void:
	if _sprite == null:
		return
	_sprite.scale = Vector2(1.15, 0.8)
	var tween := create_tween()
	tween.tween_property(_sprite, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
