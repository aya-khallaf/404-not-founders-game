extends Control
## Ending screen: all three portals clear, ship is fixed, going home.

func _ready() -> void:
	($StatsLabel as Label).text = "PORTALS %d/3 CLEAR\nBLUE:%s RED:%s ECHO:%s" % [
		Global.done_count(),
		"OK" if Global.blue_done else "--",
		"OK" if Global.red_done else "--",
		"OK" if Global.echo_done else "--",
	]

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		Global.reset_progress()
		get_tree().change_scene_to_file("res://hub.tscn")
