extends NavdiSolePlayer

@export var candrop : bool = true
@export var canpick : bool = true

enum { FLORBUF, JUMPBUF, TURNBUF, SQUATBUF, NOPLAYBUF }
@onready var bufs = Bufs.Make(self).setup_bufons([FLORBUF,6,JUMPBUF,6,TURNBUF,6,SQUATBUF,2,NOPLAYBUF,6])

var vx : float;
var vy : float;

@onready var mover = $mover
@onready var cast = $mover/cast
var _carrying_key : bool = false
var carrying_key : bool :
	get : return _carrying_key
	set(k) :
		_carrying_key = k
		mover = $mover_heavy if k else $mover
		cast = mover.get_node("cast")
		$carried_key.visible = k
		$keytriggerman/CollisionShape2D.disabled = !k
		if bufs.has(NOPLAYBUF): pass
		elif k: $keypick.play()
		else: $keyput.play()
		

func _ready() -> void:
	super._ready()
	bufs.on(NOPLAYBUF)
	carrying_key = true

func _physics_process(_delta: float) -> void:
	if position.y > (15 if carrying_key else 0) + 160 + (300-160)/2:
		escape(0)
		# blank song
		LiveDream.GetDream(self).songlink_signal.emit("https://www.beepbox.co/#9n31s0k0l00e03t2ma7g0fj07r1i0o432T1v1uc3f10v3q011d23A1F0B2Q0950Pc454E26327aT1v1ud5f10q5q83231d23A1FeBfQ021ePf34fE2612626T1v1uc7f10l5q011d35A6F1B2Q5209Pca84E1622T2v1u15f10w4qw02d03w0E0b4h400000000h4g000000014h000000004h400000000p16000000")
	
	var dpad = Pin.get_dpad()
	vy = move_toward(vy, 2, 0.07)
	
	if Pin.get_jump_hit():
		bufs.on(JUMPBUF)
	var onfloor:bool = (vy >= 0 and
		mover.cast_fraction(self, cast, VERTICAL, 1) < 1)
	if !onfloor: vx *= 0.95
	var squatting:bool = onfloor and Pin.get_plant_held()
	if squatting:
		dpad.x = 0
		bufs.on(SQUATBUF)
	elif onfloor and bufs.has(SQUATBUF):
		if carrying_key:
			if candrop:
				vy = -1.0
				onfloor = false
				bufs.clr(FLORBUF)
				var keyDropped = load("res://dreamlands/02a-redkey/loose_key.tscn").instantiate()
				keyDropped.position = position
				var room = LiveDream.GetRoom(self)
				room.add_child(keyDropped)
				keyDropped.owner = room.owner if room.owner else room
				position.y -= 5
				carrying_key = false
		else:
			if canpick and $keycast.is_colliding():
				var keyPickup = $keycast.get_collider(0)
				if keyPickup:
					keyPickup.queue_free()
					$carried_key.position = keyPickup.position - position
					carrying_key = true
					vy = 1.0
					onfloor = false
					bufs.clr(FLORBUF)
	
	if carrying_key: vx *= 0.9
	vx = move_toward(vx*0.9, 2*dpad.x, 0.08 if _carrying_key else 0.12)
	
	if onfloor:
		bufs.on(FLORBUF)
	if bufs.try_eat([FLORBUF,JUMPBUF]):
		vy = -2.2
		if carrying_key: vy *= 0.7
	if!mover.try_slip_move(self, cast, HORIZONTAL, vx):
		vx = 0;
	if!mover.try_slip_move(self, cast, VERTICAL, vy):
		vy = 0;
	
	if dpad.x:
		if $spr.flip_h != (dpad.x < 0):
			$spr.flip_h = (dpad.x < 0)
			bufs.on(TURNBUF)
	if bufs.has(TURNBUF):
		$spr.setup(
			[36] if _carrying_key else
			[26])
	elif onfloor:
		if squatting:
			$spr.setup(
				[35] if _carrying_key else
				[25])
		elif dpad.x:
			#if not $footstep.playing:
				#if carrying_key:
					#$footstep.pitch_scale = randf_range(0.5,0.6)
					#$footstep.play()
				#else:
					#$footstep.pitch_scale = randf_range(0.7,0.8)
					#$footstep.play()
			$spr.setup(
				[34,34,32,33,33,32] if _carrying_key else
				[24,24,22,23,23,22],
				8 if _carrying_key else
				4)
		else:
			$spr.setup(
				[32,32,32,32,35,35,35,32] if _carrying_key else
				[22,22,22,23,22,22,22,24],26)
	else:
		$spr.setup(
			[33] if _carrying_key else
			[23])

	$carried_key.position = (
		0.5 * $carried_key.position +
		0.5 * Vector2(0,-7 if $spr.frame == 35 else -8)
	)


func _on_exit_detector_area_entered(area: Area2D) -> void:
	escape(0)
