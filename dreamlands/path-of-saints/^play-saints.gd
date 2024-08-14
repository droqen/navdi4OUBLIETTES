extends Node

func play(dream:LiveDream) -> void:
	dream.goto_new_land(
		load(
			"res://dreamlands/path-of-saints/saints-path.tscn"
		).instantiate(),
		"rmA"
		#"rmVaultApproach3"
	)
