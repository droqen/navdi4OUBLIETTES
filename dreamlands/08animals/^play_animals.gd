extends Node2D
func play(d:LiveDream)->void:
	d.goto_new_land(
		load("res://dreamlands/08animals/animalsLAND.tscn").instantiate(),
		"floor1"
	)
	# pass
