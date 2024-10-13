extends Node

func play(d:LiveDream):
	d.goto_new_land(
		load(
			"res://dreamlands/13cavernous/cavernLand.tscn"
		).instantiate(),
		"rmA"
	)
