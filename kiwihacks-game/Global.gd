extends Node
var player_node = null

# Portal progress: set by each challenge, read by the hub + ending.
var blue_done := false
var red_done := false
var echo_done := false

func all_done() -> bool:
	return blue_done and red_done and echo_done

func done_count() -> int:
	var n := 0
	if blue_done:
		n += 1
	if red_done:
		n += 1
	if echo_done:
		n += 1
	return n

func reset_progress() -> void:
	player_node = null
	blue_done = false
	red_done = false
	echo_done = false
