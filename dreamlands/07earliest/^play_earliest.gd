extends Node

func play(d:LiveDream):
	d.goto_new_land(
		load(
			"res://dreamlands/07earliest/earliestLand.tscn"
		).instantiate(),
		"rmA"
	)
	await d.player_escaped
	d.windfish_lucidwake.emit("END")
	d.goto_new_land(
		load(
			"res://dreamlands/07earliest/earliestLand.tscn"
		).instantiate(),
		"rm6"
	)
	
