extends Node

func play(dream:LiveDream) -> void:
	dream.goto_new_land(
		load(
			"res://dreamlands/anothertest/anotherland.tscn"
		).instantiate(),
		"rmA"
	)
