extends NavdiSolePlayer

enum { FLORBUF, PINJUMPBUF }

var vel : Vector2 # velocity
var onfloor : bool
var bufs : Bufs = Bufs.Make(self).setup_bufons([
	FLORBUF,4,
	PINJUMPBUF,4,
])

func _physics_process(_delta: float) -> void:
	var dpad : Vector2i = Vector2i(
		(1 if Input.is_action_pressed("right") else 0)
		-(1 if Input.is_action_pressed("left") else 0),
		0
	)
	if Input.is_action_just_pressed("jump"): bufs.on(PINJUMPBUF)
	var jumpheld : bool = Input.is_action_pressed("jump")

	if dpad.x: $SheetSprite.flip_h = (dpad.x < 0)

	var prev_onfloor = onfloor
	onfloor = vel.y >= 0 and $mover.cast_fraction(self, $mover/solidcast, VERTICAL, 1) < 1
	if onfloor: bufs.on(FLORBUF)
	if prev_onfloor and not onfloor: vel.x *= 0.75; position.y += 0.5 # drop
	
	if vel.y < 0 and not jumpheld: vel.y = move_toward(vel.y, 0.0, 0.07)
	
	vel.x = move_toward(vel.x, dpad.x*1.0, 0.3)
	vel.y = move_toward(vel.y, 2.0, 0.05)
	var free_space_overhead : bool = $mover.cast_fraction(self, $mover/solidcast, VERTICAL, -1.5) >= 1
	#if free_space_overhead and bufs.try_eat([PINJUMPBUF]):
		#if bufs.try_eat([FLORBUF]): vel.y = -1.4
		#else: vel.y = min(vel.y, -1.0) # infinite airjumps
		#if dpad.x: vel.x = lerp(vel.x, dpad.x*1.0, 0.4)
		#onfloor = false
	if free_space_overhead and bufs.try_eat([PINJUMPBUF, FLORBUF]):
		vel.y = min(vel.y, -1.40)
		if dpad.x: vel.x = lerp(vel.x, dpad.x*1.0, 0.4)
		onfloor = false
	
	if not $mover.try_slip_move(self, $mover/solidcast, HORIZONTAL, vel.x):
		vel.x = 0
	if not $mover.try_slip_move(self, $mover/solidcast, VERTICAL, vel.y):
		vel.y = 0
