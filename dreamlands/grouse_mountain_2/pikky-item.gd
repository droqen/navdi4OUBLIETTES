extends Node2D

@export var is_jewel : bool
@export var is_worm : bool

var falling : bool = true # always starts true
var yvel : float = 0.0

func _physics_process(delta: float) -> void:
	if falling:
		yvel += 0.1
		if not $mover.try_slip_move(self, $mover/ShapeCast2D, VERTICAL, yvel):
			yvel = 0.0
			falling = false # done!
