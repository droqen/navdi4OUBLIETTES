extends Node
func play(d:LiveDream)->void:
	d.goto_new_land(
		load(
			"res://dreamlands/24notfound/notfoundland.tscn"
		).instantiate(),
		"rmBeige"
	)
	await d.player_escaped
	d.goto_new_land(
		load(
			"res://dreamlands/24notfound/notfoundland.tscn"
		).instantiate(),
		"rmNoirEND"
	)
	d.windfish_awakened.emit()
