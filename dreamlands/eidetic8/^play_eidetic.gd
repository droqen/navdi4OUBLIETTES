extends Node

@onready var dream : LiveDream = get_parent()
const LAND = preload("res://dreamlands/eidetic8/eidetic8land.tscn")

func _ready() -> void:
	dream.goto_new_land(
		LAND.instantiate(),
		"rmA"
	)
	dream.player_escaped.connect(func(escape_code):
		if escape_code == "respawn":
			NavdiSolePlayer.ClearPlayer(self)
			dream.goto_new_land(
				LAND.instantiate(),
				"rmA"
			)
	)
	#print("player escaped.")
	#dream.goto_new_land(
		#load(
			#"res://dreamlands/desert-archive/DesertArchiveLAND_Post.tscn"
		#).instantiate(),
		#"rmDeep4"
	#)
