extends Node
func play(d:LiveDream)->void:
	d.camera.enabled = false
	d.goto_new_land(
		load(
			"res://dreamlands/this-second-kind-of-fire/fire2LAND.tscn"
		).instantiate(),
		"rmA"
	)
	#await get_tree().process_frame
	#F2FlagCheckpoint.ActiveCheckName = "check3"
	#NavdiSolePlayer.GetPlayer(self).die()
