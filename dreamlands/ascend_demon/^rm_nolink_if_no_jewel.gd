extends Node

@export var index : int = 0
@export var allowed_string : String = "rmPastTheWall"
@export var disallowed_string : String = ""

func _physics_process(delta: float) -> void:
	if VictoryJewel.AnyJewelCollected:
		get_parent().room_links[index] = allowed_string
	else:
		get_parent().room_links[index] = disallowed_string
