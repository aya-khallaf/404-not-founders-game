extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


var speed = 400
@export var in_spaceship = false
var health = 100
var max_health = 100
var iframes = 0.0
var dead = false

func take_damage(amount: int) -> void:
	if dead or iframes > 0.0:
		return
	health = maxi(0, health - amount)
	iframes = 0.8
	_flash()

func _die() -> void:
	dead = true
	Global.player_node = null
	velocity = Vector2.ZERO
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	var dim := ColorRect.new()
	dim.color = Color(0.4, 0, 0, 0.45)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(dim)
	var label := Label.new()
	label.text = "HULL DOWN"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 48)
	label.add_theme_color_override("font_color", Color(1, 0.3, 0.25, 1))
	label.set_anchors_preset(Control.PRESET_CENTER)
	label.position = Vector2(-200, -40)
	label.size = Vector2(400, 80)
	layer.add_child(label)
	await get_tree().create_timer(1.2).timeout
	get_tree().reload_current_scene()

func _ready() -> void:
	animated_sprite_2d.play("walk")
	Global.player_node = self

func _physics_process(delta):
	$ProgressBar.value = health
	$ProgressBar.max_value = max_health
	iframes = maxf(0.0, iframes - delta)
	if iframes > 0.0:
		animated_sprite_2d.modulate.a = 0.35 + 0.65 * absf(sin(Time.get_ticks_msec() / 70.0))
	else:
		animated_sprite_2d.modulate.a = 1.0
	if dead:
		return
	if health<=0:
		_die()
		return
	if in_spaceship:
		animated_sprite_2d.play("spaceship")
		speed = 800
	else:
		animated_sprite_2d.play("walk")
		speed = 400
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed

	move_and_slide()

func _flash() -> void:
	var tween := create_tween()
	tween.tween_property(animated_sprite_2d, "modulate", Color(2, 0.4, 0.4, 1), 0.06)
	tween.tween_property(animated_sprite_2d, "modulate", Color(1, 1, 1, 1), 0.12)
