extends Node
func play(d:LiveDream)->void:
	d.goto_new_land(
		load("res://dreamlands/wings-groundless/groundLAND.tscn").instantiate(),
		"rmA"
	)
