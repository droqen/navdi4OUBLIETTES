extends Node
func play(d:LiveDream)->void:
	d.goto_new_land(
		load(
			"res://dreamlands/a-simple-jump/asjumpland.tscn"
		).instantiate(),
		"rmA"
	)
