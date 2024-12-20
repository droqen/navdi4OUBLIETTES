extends NavdiSolePlayer

var vx:float;var vy:float;
@onready var spr = $SheetSprite
@onready var mover = $NavdiBodyMover
@onready var castr = $NavdiBodyMover/ShapeCast2D
enum { AIRJUMPEDBUF, }
var bufs : Bufs = Bufs.Make(self).setup_bufons([ AIRJUMPEDBUF,4, ])
var dead : bool = false
func _physics_process(_delta: float) -> void:
	
	if dead:
		vx=move_toward(vx*0.9, 0.0, 0.125)
		vy=move_toward(vy, 0.05, 0.001)
		spr.setup([79], 0)
		if vx and!mover.try_slip_move(self,castr,HORIZONTAL,vx):
			vx = 0
		if vy and!mover.try_slip_move(self,castr,VERTICAL,vy):
			vy = 0
		return
	
	var dpad = Pin.get_dpad()
	var floor=vy>=0 and mover.cast_fraction(self,castr,VERTICAL,1)<1
	vx = move_toward(vx*0.9, 1.0*dpad.x, 0.125)
	if Pin.get_jump_hit(): vy = -0.8; bufs.on(AIRJUMPEDBUF)
	if Pin.get_jump_held(): vy=move_toward(vy,0.5,0.015)
	else: vy=move_toward(vy,1.3,0.04)
	
	if vx and!mover.try_slip_move(self,castr,HORIZONTAL,vx):
		vx = 0
	if vy and!mover.try_slip_move(self,castr,VERTICAL,vy):
		vy = 0
		
	if dpad.x: spr.flip_h = dpad.x < 0
	
	if floor:
		if dpad.x:
			if spr.ani_period!=8:
				match spr.frame:
					66: spr.setup([65,67,65,66],8)
					_: spr.setup([66,65,67,65],8)
		elif spr.ani_period!=8 or spr.frame==65:
			spr.setup([65], 0)
	else:
		if bufs.has(AIRJUMPEDBUF):
			spr.setup([67], 0)
		elif Pin.get_jump_held():
			if vy >= 0.5:
				spr.setup([69,66,68,66],3)
			elif vy > 0:
				spr.setup([66,69],10)
			else:
				spr.setup([67,68],10)
		else:
			spr.setup([66], 0)

func _on_spike_detector_body_entered(_body: Node2D) -> void:
	if!dead:
		vy = 0
		dead = true
		spr.rotation = randf_range(0.3,0.5)*[-1,1][randi()%2]
		LiveDream.GetDream(self).windfish_awakened.emit()
