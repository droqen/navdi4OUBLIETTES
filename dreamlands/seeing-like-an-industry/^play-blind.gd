extends Node
func play(dream:LiveDream) -> void:
	dream.goto_new_land(
		load(
			"res://dreamlands/seeing-like-an-industry/blindLAND.tscn"
		).instantiate(),
		#"rmA2Downstairs"
		"rmDenseCityStart"
	)
