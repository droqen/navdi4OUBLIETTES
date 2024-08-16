extends Node2D

enum { JUMPBUF, FLORBUF, ONWALLBUF, HURTBUF, STUNBUF, }
@onready var bufs : Bufs = Bufs.Make(self).setup_bufons([
	JUMPBUF,4, FLORBUF,4,
])

@onready var spr : SheetSprite = $spr
@onready var mover : NavdiBodyMover = $mover
@onready var cast : ShapeCast2D = $mover/solidcast
var dpad : Vector2i; var jumphit : bool; var jumpheld : bool;
var onfloor : bool; var onwalldir : int;
var vx : float; var vy : float;

func _physics_process(_delta: float) -> void:
	dpad = Pin.get_dpad()
	jumphit = Pin.get_jump_hit()
	jumpheld = Pin.get_jump_held()
	if dpad.x: spr.flip_h = dpad.x < 0
	if jumphit: bufs.on(JUMPBUF)
	vx = move_toward(vx, dpad.x * 1.0, 0.1)
	vy = move_toward(vy, 1.5, 0.02)
	if bufs.try_eat([JUMPBUF, FLORBUF]): vy = -1.5
	onfloor = vy >= 0 and mover.cast_fraction(self, cast, VERTICAL, 1) < 1
	if onfloor: bufs.on(FLORBUF)
	if not mover.try_slip_move(self, cast, HORIZONTAL, vx): vx = 0
	if not mover.try_slip_move(self, cast, VERTICAL, vy): vy = 0
