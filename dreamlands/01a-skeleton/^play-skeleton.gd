extends Node
func play(d:LiveDream)->void:
	d.goto_new_land(
		load("res://dreamlands/01a-skeleton/teoskeletonLAND.tscn"
		).instantiate(),
		"rmA"
	)
	await d.player_escaped
	d.goto_new_land(
		load("res://dreamlands/01a-skeleton/teoskeletonLAND.tscn"
		).instantiate(),
		"rmB"
	)
	
	#d.goto_new_land(
		#load("res://dreamlands/01a-skeleton/teoskeletonLAND.tscn"
		#).instantiate(),
		#"rmCTest"
	#)
	
	await d.player_escaped
	
	d.windfish_awakened.emit()
	
	d.goto_new_land(
		load("res://dreamlands/01a-skeleton/teoskeletonLAND.tscn"
		).instantiate(),
		"rmEnding"
	)
	
