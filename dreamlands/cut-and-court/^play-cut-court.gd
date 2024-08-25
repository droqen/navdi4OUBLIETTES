extends Node
func play(d:LiveDream) -> void:
	#d.goto_new_land(
		#load("res://dreamlands/cut-and-court/cut-court-land.tscn").instantiate(),
		#"rmA"
		##"rmMoonBtwn"
	#)
	#var escapecode = await d.player_escaped
	d.goto_new_land(
		load("res://dreamlands/cut-and-court/goddess-land.tscn").instantiate(),
		"rmA"
	)
