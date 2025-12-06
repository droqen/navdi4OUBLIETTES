extends Node

@export var player : Node
@export var chatterlabel : ChatterLabel

var windfish_called : bool = false

func _physics_process(_delta: float) -> void:
	if player.slidey <= 0:
		chatterlabel.printing = true
	else:
		chatterlabel.printing = false

	if chatterlabel.visible_ratio <= 0:
		if not windfish_called:
			print("ok, done")
			windfish_called = true
