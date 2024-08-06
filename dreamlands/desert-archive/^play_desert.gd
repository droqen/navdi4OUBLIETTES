extends Node

@onready var dream : LiveDream = get_parent()

func _ready() -> void:
	land_desert()
	
func land_desert():
	dream.goto_new_land(
		load(
			"res://dreamlands/desert-archive/DesertArchiveLAND.tscn"
		).instantiate(),
		"rmA"
	)
	await dream.player_escaped
	print("player escaped.")
	dream.goto_new_land(
		load(
			"res://dreamlands/desert-archive/DesertArchiveLAND_Post.tscn"
		).instantiate(),
		"rmDeep4"
	)
