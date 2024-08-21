extends Node
func play(dream:LiveDream)->void:
	dream.goto_new_land(
		load(
			"res://dreamlands/a-thing-of-beauty/beautyLand.tscn"
		).instantiate(),
		"rmTopRight"
	)
	await dream.player_escaped
	dream.goto_new_land(
		load(
			"res://dreamlands/a-thing-of-beauty/beautyLand.tscn"
		).instantiate(),
		"rmEnd"
	)
	dream.windfish_lucidwake.emit("CLOSER")
