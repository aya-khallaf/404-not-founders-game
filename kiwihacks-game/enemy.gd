extends CharacterBody2D

const SPEED = 300.0
@export var animation := ""

var touching_player = false
var cooldown = false
var health = 100
var max_health = 100

func _ready() -> void:
	$AnimatedSprite2D.animation = animation

func _physics_process(delta: float) -> void:
	$ProgressBar.value=health
	$ProgressBar.max_value=max_health
	if Global.player_node:
		var direction = (Global.player_node.global_position - global_position).normalized()

		if not touching_player:
			velocity = direction * SPEED
		else:
			velocity = Vector2.ZERO
			
		if touching_player and not cooldown:
			Global.player_node.health -= 5
			cooldown = true
			$Timer.start()

	move_and_slide()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body == Global.player_node:
		touching_player = true


func _on_hitbox_body_exited(body: Node2D) -> void:
	if body == Global.player_node:
		touching_player = false


func _on_timer_timeout() -> void:
	cooldown = false


func _on_hitbox_area_entered(area: Area2D) -> void:
	health-=10
	if health<=0:
		queue_free()


func _on_hitbox_area_exited(area: Area2D) -> void:
	pass # Replace with function body.
