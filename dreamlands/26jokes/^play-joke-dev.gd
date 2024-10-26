extends Node
func play(d:LiveDream)->void:
	d.goto_new_land(
		load(
			"res://dreamlands/26jokes/jokeland.tscn"
		).instantiate(),
		"rmA"
	)
