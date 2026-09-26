extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

<<<<<<< Updated upstream

var speed = 400
@export var in_spaceship = false

func _ready() -> void:
	animated_sprite_2d.play("walk")
	Global.player_node = self
=======
var speed = 400

func _ready() -> void:
	animated_sprite_2d.play("walk")
>>>>>>> Stashed changes

func _physics_process(delta):
	if in_spaceship:
		animated_sprite_2d.play("spaceship")
		speed = 800
	else:
		animated_sprite_2d.play("walk")
		speed = 400
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed

	move_and_slide()


func _on_animated_sprite_2d_animation_looped() -> void:
	animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h
