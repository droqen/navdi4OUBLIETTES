extends NavdiSolePlayer

enum { JUMPBUF, FLORBUF, ONWALLBUF, WALLJUMPEDBUF, HURTBUF, STUNBUF, }
@onready var bufs : Bufs = Bufs.Make(self).setup_bufons([
	JUMPBUF,4, FLORBUF,4, ONWALLBUF,4,
	WALLJUMPEDBUF,6,
])

@onready var spr : SheetSprite = $spr
@onready var mover : NavdiBodyMover = $mover
@onready var cast : ShapeCast2D = $mover/solidcast
var dpad : Vector2i; var jumphit : bool; var jumpheld : bool; var duckheld : bool;
var onfloor : bool; var onwall : bool;
var onwalldir : int; var walljumpeddir : int;
var vx : float; var vy : float;
var ducking : bool; var ducking_charge : int = 0;

func _physics_process(_delta: float) -> void:
	dpad = Pin.get_dpad(); if ducking: dpad = Vector2i.ZERO;
	jumphit = Pin.get_jump_hit()
	jumpheld = Pin.get_jump_held()
	duckheld = Pin.get_plant_held()
	
	if onwall: spr.flip_h = onwalldir < 0
	elif dpad.x: spr.flip_h = dpad.x < 0
	
	if jumphit: bufs.on(JUMPBUF)
	if bufs.has(WALLJUMPEDBUF):
		vy = -1.0;
		vx = walljumpeddir * 1.5;
	elif walljumpeddir != 0:
		var vx2 : float = dpad.x * 1.0 + 0.5 * walljumpeddir
		vx = move_toward(vx, vx2, 0.05)
	else:
		vx = move_toward(vx, dpad.x * 1.0, 0.1)
	if onwall:
		if vy > 0:
			vy = move_toward(vy, 1.5, 0.02) # reduced gravity
		else:
			vy = move_toward(vy, 1.5, 0.02) # *mildly* reduced gravity
	else:
		vy = move_toward(vy, 1.5, 0.04)
	if bufs.try_eat([JUMPBUF, ONWALLBUF]):
		vy = -1.0;
		walljumpeddir = -onwalldir;
		vx = walljumpeddir * 1.5;
		bufs.on(WALLJUMPEDBUF)
	if bufs.try_eat([JUMPBUF, FLORBUF]):
		vy = -0.95;
	onfloor = vy >= 0 and mover.cast_fraction(self, cast, VERTICAL, 1) < 1
	if onfloor:
		bufs.on(FLORBUF)
		walljumpeddir = 0
		if not ducking: ducking_charge = 0
		if duckheld and ducking_charge < 100:
			if not ducking: ducking = true; ducking_charge = 0
			ducking_charge += 2
		elif ducking:
			ducking = false;
			vy = remap(ducking_charge as float, 0.0, 100.0, -0.5, -1.4)
	else:
		ducking = false
	onwall = false
	if ((dpad.x > 0 or walljumpeddir > 0 or bufs.has(ONWALLBUF))
		and mover.cast_fraction(self, cast, HORIZONTAL, 1) < 1):
			onwall = true; onwalldir = 1;
	if ((dpad.x < 0 or walljumpeddir < 0 or bufs.has(ONWALLBUF))
		and mover.cast_fraction(self, cast, HORIZONTAL, -1) < 1):
			onwall = true; onwalldir = -1;
	if onwall:
		if not bufs.has(ONWALLBUF) and vy > 0: vy = 0.0 # stop
		bufs.on(ONWALLBUF);
		if not bufs.has(WALLJUMPEDBUF): walljumpeddir = 0;
	if not mover.try_slip_move(self, cast, HORIZONTAL, vx): vx = 0
	if not mover.try_slip_move(self, cast, VERTICAL, vy): vy = 0
	
	if onwall:
		spr.setup([31])
		ducking = false
	elif onfloor:
		if ducking:
			if ducking_charge >= 75: spr.setup([36,37],3)
			elif ducking_charge >= 25: spr.setup([36,37],10)
			else: spr.setup([35])
		elif dpad.x: spr.setup([30,32],10)
		else: spr.setup([30])
	else:
		ducking = false
		var vxfwd : float = vx * (-1 if spr.flip_h else 1)
		if vxfwd > 0.9: spr.setup([34])
		elif vxfwd < 0: spr.setup([33])
		else: spr.setup([32])
