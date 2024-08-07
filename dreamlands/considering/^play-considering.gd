extends Node

@onready var dream : LiveDream = get_parent()

func _ready() -> void:
	play_considering()
	
func play_considering():
	dream.goto_new_land(
		load(
			"res://dreamlands/considering/considering-land.tscn"
		).instantiate(),
		"rmA"
	)
