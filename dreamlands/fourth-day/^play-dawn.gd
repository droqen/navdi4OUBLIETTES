extends Node
func play(dream:LiveDream) -> void:
	dream.goto_new_land(
		load(
			"res://dreamlands/fourth-day/fourth-land.tscn"
		).instantiate(),
		"rmA"
	)
