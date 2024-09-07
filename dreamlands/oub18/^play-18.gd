extends Node
func play(d:LiveDream):
	d.goto_new_land(
		load("res://dreamlands/oub18/oub18land.tscn").instantiate(),
		"rmA"
	)
