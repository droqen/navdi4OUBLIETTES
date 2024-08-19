extends Node
func play(dream:LiveDream) -> void:
	dream.goto_new_land(
		load("res://dreamlands/very-very-explicit/explicitLAND.tscn").instantiate(),
		"rmA"
	)
