extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var speed = 400

func _ready() -> void:
	animated_sprite_2d.play("walk")

func _physics_process(delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed

	move_and_slide()


func _on_animated_sprite_2d_animation_looped() -> void:
	animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h
