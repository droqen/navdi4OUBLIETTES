extends Node

var blink : int = 0
func _physics_process(_delta: float) -> void:
	blink += 1
	if blink == 30: get_parent().hide()
	if blink > 60: get_parent().show(); blink = 0;
