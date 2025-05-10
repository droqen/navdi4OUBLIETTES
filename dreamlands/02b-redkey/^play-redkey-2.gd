extends Node
func play(d:LiveDream) -> void:
	d.goto_new_land(load(
		"res://dreamlands/02b-redkey/missredkeyLAND.tscn"
	).instantiate(),"rmA")
	await d.player_escaped
	d.windfish_awakened.emit(0)
	d.goto_new_land(load(
		"res://dreamlands/02b-redkey/missredkeyLAND.tscn"
	).instantiate(),"rmEnding")
