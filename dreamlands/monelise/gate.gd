extends StaticBody2D

var hp : int = 3

var hitbuf : int = 0

func take_damage() -> void:
	hp -= 1
	if hitbuf <= 0:
		hitbuf = 10
		$a.setup([17]); $b.setup([17])

func _physics_process(delta: float) -> void:
	if hitbuf > 0:
		hitbuf -= 1
		if hitbuf == 5:
			match hp:
				3: $a.setup([7]); $b.setup([7]);
				2: $a.setup([8]); $b.setup([8]);
				1: $a.setup([9]); $b.setup([9]);
				0, _: queue_free() # delete me
