extends Node
func play(d:LiveDream) -> void:
	d.goto_new_land(
		load(
			"res://dreamlands/04b-door/doorLAND.tscn"
		).instantiate(),
		"rmA"
	)
	await d.player_escaped
	d.windfish_awakened.emit()
