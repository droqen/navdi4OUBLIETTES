extends Node

func _ready() -> void:
	var dream : LiveDream = get_parent()
	var TestOublietteLand : DreamLand = load(
		"res://dreamlands/template/TestOubliette.tscn").instantiate()
	var firstlevelname = "rmCaveStory1"
	
	dream.goto_new_land(TestOublietteLand, firstlevelname)
	
	await dream.player_escaped
	
	dream.goto_new_land(TestOublietteLand, "rmEnding")
	
	# end
