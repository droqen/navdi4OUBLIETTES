extends Node

@onready var dream : LiveDream = get_parent()

func _ready() -> void:
	dream.goto_new_land(
		load(
			"res://dreamlands/kafkatrask/kafkatraskLAND.tscn"
		).instantiate(),
		"rmA"
	)
