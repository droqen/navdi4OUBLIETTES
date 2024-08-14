extends Node

func play(dream:LiveDream) -> void:
	dream.goto_new_land(
		load(
			"res://dreamlands/path-of-saints/saints-path.tscn"
		).instantiate(),
		"rmA"
		#"rmVault2"
	)
	dream.player_escaped.connect(func(_code): dream.windfish_awakened.emit())
