extends Node
func play(d:LiveDream)->void:
	d.goto_new_land(
		load(
			"res://dreamlands/a-simple-jump/asjumpland.tscn"
		).instantiate(),
		"rmA"
	)
	await d.player_escaped
	d.windfish_lucidwake.emit("A")
	d.goto_new_land(
		load(
			"res://dreamlands/a-simple-jump/asjumpland.tscn"
		).instantiate(),
		"rmEnd"
	)
