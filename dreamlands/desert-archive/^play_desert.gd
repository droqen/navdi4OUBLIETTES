extends Node

@onready var dream : LiveDream = get_parent()

func _ready() -> void:
	land_kafkatrask()
	
func land_kafkatrask():
	dream.goto_new_land(
		load(
			"res://dreamlands/desert-archive/DesertArchiveLAND.tscn"
		).instantiate(),
		"rmSun"
	)
