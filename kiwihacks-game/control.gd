extends Control


func _ready() -> void:
	$RichTextLabel2.visible_characters = 0
	var hint := Label.new()
	hint.name = "ContinueHint"
	hint.text = "PRESS ENTER OR CLICK TO BEGIN"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 28)
	hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
	hint.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	hint.offset_top = -80
	add_child(hint)


func _unhandled_input(event: InputEvent) -> void:
	var clicked := event is InputEventMouseButton and event.pressed
	if event.is_action_pressed("ui_accept") or clicked:
		get_tree().change_scene_to_file("res://hub.tscn")
	

func _on_timer_timeout() -> void:
	$RichTextLabel2.visible_characters+=1
	if $RichTextLabel2.visible_characters == len($RichTextLabel2.text):
		return
	else:
		$Timer.start()
