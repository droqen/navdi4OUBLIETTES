extends Node
func play(d:LiveDream)->void:
	d.goto_new_land(
		load("res://dreamlands/02a-redkey/teoredkeyLAND.tscn"\
		).instantiate(),
		"rmStart"
	)
	await d.player_escaped
	d.windfish_awakened.emit()
