extends Node

func _ready() -> void:
	var dream : LiveDream = get_parent()
	var land : DreamLand = load(
		"res://dreamlands/235/land.tscn").instantiate()
	var firstlevelname = "rm1"
	
	dream.goto_new_land(land, "rm1")
	await dream.player_escaped
	dream.goto_new_land(land, "rmEnd")
	
	# end
