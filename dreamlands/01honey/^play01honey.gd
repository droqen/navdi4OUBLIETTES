extends Node

func play(d:LiveDream)->void:
	d.goto_new_land(
		load(
			"res://dreamlands/01honey/honeyland.tscn"
		).instantiate(),
		"rmA"
	)
