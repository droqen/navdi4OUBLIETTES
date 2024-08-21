extends Node
func play(dream:LiveDream)->void:
	dream.goto_new_land(
		load(
			"res://dreamlands/a-thing-of-beauty/beautyLand.tscn"
		).instantiate(),
		"rmTopRight"
	)
