extends NavdiSolePlayer

enum {Jumpbuf,Florbuf,Revivedbuf}
var bufs = Bufs.Make(self).setup_bufons([
	Jumpbuf,4,Florbuf,16,Revivedbuf,60,
])

@onready var spr : SheetSprite = $SheetSprite
@onready var mover : NavdiBodyMover = $NavdiBodyMover
@onready var caster : ShapeCast2D = $NavdiBodyMover/ShapeCast2D

var vx:float;var vy:float;
var ducking:bool;
var ffalling:bool;
var last_safe_room_name:String=''
var last_safe_cell:Vector2i=Vector2i(12,12)

func _physics_process(_delta: float) -> void:
	if bufs.has(Revivedbuf):
		if bufs.read(Revivedbuf) > 30: vx = 0
		else: vx = clamp(vx,-0.5,0.5)
		if vy < 0: bufs.clr(Revivedbuf); show()
		elif bufs.read(Revivedbuf) % 5 > 3: hide()
		else: show()
	var dpad = Pin.get_dpad()
	if Pin.get_jump_hit():bufs.on(Jumpbuf)
	var tofloor : float = mover.cast_fraction(self,caster,VERTICAL,1)
	if tofloor < 1:
		var maze : Maze = LiveDream.GetMaze(self)
		if maze:
			var cell : Vector2i = maze.local_to_map(self.position)
			if maze.is_cell_solid(cell+Vector2i.DOWN):
				if last_safe_cell != cell:
					last_safe_cell = cell
					last_safe_room_name = LiveDream.GetRoom(self).name
	if bufs.has(Florbuf) and vy > 0: vy = 0
	ducking = false; ffalling = false;
	if Pin.get_plant_held():
		if not bufs.has(Florbuf):
			ffalling = true
		elif dpad.x or tofloor < 1:
			ducking = true
		else:
			pass
	if ducking:
		if bufs.has(Florbuf): bufs.on(Florbuf);
	if ducking or ffalling:
		vy=move_toward(vy,3.0,0.04);
	if dpad.x:spr.flip_h=dpad.x<0
	if bufs.try_eat([Florbuf, Jumpbuf]): vy=-0.8
	if vy>=0:
		if tofloor < 1: position.y += tofloor; bufs.on(Florbuf); vy = 0;
	if ducking:
		vx=move_toward(vx,dpad.x*1.2,0.08)
	else:
		vx=move_toward(vx,dpad.x,0.1)
	vy=move_toward(vy,3.0,0.031)
	if vy!=0 and not mover.try_move(self,caster,VERTICAL,vy):
		vy=0
	if vx!=0 and not mover.try_slip_move(self,caster,HORIZONTAL,vx):
		vx=0
	if bufs.has(Florbuf):
		# on floor
		if ducking:
			if dpad.x: spr.setup([33,34,33,],3)
			else: spr.setup([32])
		else:
			if dpad.x: spr.setup([31,21,31,],4)
			else: spr.setup([21])
	else:
		if ffalling:
			spr.setup([35,36],4)
		else:
			var fwdvx:float=vx
			if spr.flip_h:fwdvx=-fwdvx
			if fwdvx>0.5:spr.setup([41])
			elif fwdvx>=0.0:spr.setup([42])
			else:spr.setup([43])

func die() -> void:
	var maze : Maze = LiveDream.GetMaze(self)
	for _i in range(5):
		if maze:
			position = maze.map_to_local(last_safe_cell)
			vx = 0
			vy = 0
			bufs.on(Revivedbuf)
			var dream = LiveDream.GetDream(self)
			if dream:
				var safe_room = dream.dreamland.try_get_room_inst(last_safe_room_name)
				if dream.dreamroom != safe_room:
					dream.set_dreamroom(safe_room)
			break
		else:
			await get_tree().physics_frame
