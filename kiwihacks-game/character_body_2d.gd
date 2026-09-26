extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


var speed = 400
@export var in_spaceship = false
var health = 100
var max_health = 100

func _ready() -> void:
	animated_sprite_2d.play("walk")
	Global.player_node = self

func _physics_process(delta):
	$ProgressBar.value = health
	$ProgressBar.max_value = max_health
	if health<=0:
		get_tree().reload_current_scene()
	if in_spaceship:
		animated_sprite_2d.play("spaceship")
		speed = 800
	else:
		animated_sprite_2d.play("walk")
		speed = 400
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed

	move_and_slide()
