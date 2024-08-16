extends Node

func play(dream:LiveDream) -> void:
	dream.goto_new_land(
		load("res://dreamlands/compatible/compatibLAND.tscn").instantiate(),
		"rmA"
	)
