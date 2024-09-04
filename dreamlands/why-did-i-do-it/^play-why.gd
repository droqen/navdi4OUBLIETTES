extends Node
func play(d:LiveDream)->void:
	d.goto_new_land(
		load("res://dreamlands/why-did-i-do-it/whyLAND.tscn"
		).instantiate(),
		'rmA'
	)
	await d.player_escaped
	d.set_dreamroom(d.dreamland.try_get_room_inst('rmB'))
	await d.player_escaped
	d.set_dreamroom(d.dreamland.try_get_room_inst('rmC'))
