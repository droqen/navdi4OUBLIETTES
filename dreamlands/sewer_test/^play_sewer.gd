extends Node

func _ready() -> void:
	var land = load("res://dreamlands/sewer_test/sewerTestLand.tscn").instantiate()

	get_parent().goto_new_land(
		land,
		"rmA"
	)
	
	await get_parent().player_escaped
	
	get_parent().goto_new_land(
		land,
		"rmUnlinked"
	)
