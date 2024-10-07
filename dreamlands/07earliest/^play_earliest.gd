extends Node

func play(d:LiveDream):
	d.goto_new_land(
		load(
			"res://dreamlands/07earliest/earliestLand.tscn"
		).instantiate(),
		"rmA"
	)
	
