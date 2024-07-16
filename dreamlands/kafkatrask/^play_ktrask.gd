extends Node

@onready var dream : LiveDream = get_parent()

func _ready() -> void:
	land_kafkatrask()
	
func land_kafkatrask():
	dream.goto_new_land(
		load(
			"res://dreamlands/kafkatrask/kafkatraskLAND.tscn"
		).instantiate(),
		"rmA"
	)
	
	var code = await dream.player_escaped
	match code:
		"rmSunlight3":
			land_kafkatrask_yellow()
		_:
			land_kafkatrask()

func land_kafkatrask_yellow():
	dream.goto_new_land(
		load(
			"res://dreamlands/kafkatrask/kafkatraskLAND.tscn"
		).instantiate(),
		"rmPureYellow"
	)
	# the end.
