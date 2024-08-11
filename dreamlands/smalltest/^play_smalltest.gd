extends Node

func play(dream:LiveDream) -> void:
	dream.goto_new_land(
		load("res://dreamlands/smalltest/smallland.tscn").instantiate(),
		"rmA"
	);
