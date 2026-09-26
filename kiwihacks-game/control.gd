extends Control


func _ready() -> void:
	$RichTextLabel2.visible_characters = 0
	

func _on_timer_timeout() -> void:
	$RichTextLabel2.visible_characters+=1
	if $RichTextLabel2.visible_characters == len($RichTextLabel2.text):
		return
	else:
		$Timer.start()


func _on_musictimer_timeout() -> void:
	$AudioStreamPlayer2.playing = false
