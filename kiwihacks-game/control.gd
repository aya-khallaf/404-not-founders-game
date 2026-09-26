extends Control


func _ready() -> void:
	$RichTextLabel2.visible_characters = 0
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		get_tree().change_scene_to_file("res://hub world.tscn")
	

func _on_timer_timeout() -> void:
	$RichTextLabel2.visible_characters+=1
	if $RichTextLabel2.visible_characters == len($RichTextLabel2.text):
		return
	else:
		$Timer.start()
		
		
