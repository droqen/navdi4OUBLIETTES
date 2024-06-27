extends Node

func _enter_tree() -> void:
	try_hide()
func _physics_process(_delta: float) -> void:
	try_hide()
func try_hide():
	if get_parent().visible and VictoryJewel.AnyJewelCollected:
		get_parent().hide()
		get_parent().queue_free()
