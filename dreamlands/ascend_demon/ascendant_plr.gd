extends NavdiSolePlayer

enum {
	FLORBUF = 1000, PINJUMPBUF, PLANTINGBUF,
	PLANT_WHILEBUF = 2000, INAIR_VARVELY,
		ONGROUND_BLINKING, ONGROUND_RUNNING, SPLATTED
}

var bufs : Bufs = Bufs.Make(self).setup_bufons([
	FLORBUF,4, PINJUMPBUF,5, PLANTINGBUF,16,
])

var splatted : bool = false # (dead)

const TERMINAL_VELOCITY : float = 3.0

var sprst : TinyState = TinyState.new(ONGROUND_BLINKING, func(_then,now):
	match now:
		PLANT_WHILEBUF: $spr.setup([4])
		ONGROUND_RUNNING:
			if $spr.frame in [0,1]: $spr.setup([2,3,4,5],5)
			else: $spr.setup([4,5,2,3],5)
		ONGROUND_BLINKING: $spr.setup([0,0,0,0,1,0,0,0,0,0,1,0,1,0,0,0,],9)
		INAIR_VARVELY: pass # update_inair_spr()
		SPLATTED: pass # update_splatted_spr()
)

var vel : Vector2

const GRAVITY : float = 0.06
const QUICKFALL_GRAVITY : float = 0.12

func _ready() -> void: super._ready()
func _physics_process(_delta: float) -> void:
	# frame-only values
	var dpad : Vector2
	var onfloor : bool = vel.y >= 0 and $mover.cast_fraction(self,$mover/solidcast,VERTICAL,1.0)<1
	var do_planting : bool = bufs.has(PLANTINGBUF)
	var terminal_velocity : bool = vel.y > TERMINAL_VELOCITY
	var xcontrol : float = 0.02 if terminal_velocity else 0.1
	var do_inputs : bool = (not bufs.has(PLANTINGBUF) and not splatted)
	var jumpheld : bool
	var do_velupdate : bool = true
	var do_jumpupdate : bool = true
	var do_sprupdate : bool = true
	if do_planting:
		if vel.y >= 1.5:
			bufs.clr(PLANTINGBUF)
		elif bufs.read(PLANTINGBUF) == 1:
			print("plant!")
	if do_inputs:
		if onfloor and Pin.get_plant_hit():
			# cancel remainder of inputs
			bufs.on(PLANTINGBUF)
			vel.x = 0.0 # stop in place
			vel.y = -0.8
		else:
			dpad = Pin.get_dpad()
			if Pin.get_jump_hit(): bufs.on(PINJUMPBUF)
			jumpheld = Pin.get_jump_held()
	if do_velupdate:
		vel.x = move_toward(vel.x, 1.0 * dpad.x, 0.1)
		vel.y = move_toward(vel.y, 4.0, GRAVITY)
		if vel.y < 0 and not jumpheld: vel.y = move_toward(vel.y, 0.0, QUICKFALL_GRAVITY)
		if not $mover.try_slip_move(self, $mover/solidcast, HORIZONTAL, vel.x):
			vel.x=0
		if not $mover.try_slip_move(self, $mover/solidcast, VERTICAL, vel.y):
			vel.y=0
			if terminal_velocity:
				splatted = true
				terminal_velocity = false
				vel.y = -1.5
	if do_jumpupdate:
		if onfloor: bufs.on(FLORBUF)
		if bufs.try_eat([FLORBUF,PINJUMPBUF]):
			onfloor = false
			vel.y = -2.0
	if do_sprupdate:
		var spr : SheetSprite = $spr
		if dpad.x: spr.flip_h = dpad.x < 0
		if splatted:
			sprst.goto(SPLATTED); update_splatted_spr()
		elif bufs.read(PLANTINGBUF) > 3:
			sprst.goto(PLANT_WHILEBUF)
		elif onfloor:
			if dpad.x: sprst.goto(ONGROUND_RUNNING)
			else: sprst.goto(ONGROUND_BLINKING)
		else:
			sprst.goto(INAIR_VARVELY); update_inair_spr()

func update_splatted_spr():
	if vel.y <= 0: $spr.setup([9])
	else: $spr.setup([6])
func update_inair_spr():
	if vel.y < 0: $spr.setup([5])
	elif vel.y < 0.5: $spr.setup([2])
	elif vel.y < TERMINAL_VELOCITY: $spr.setup([3])
	else: $spr.setup([7,8],5)
