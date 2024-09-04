extends NavdiSolePlayer
enum {FLORBUF,JUMPBUF}
var bufs : Bufs = Bufs.Make(self).setup_bufons([FLORBUF,4,JUMPBUF,4,])
@onready var spr = $spr
@onready var mover = $mover
@onready var caster = $mover/caster
var vx:float; var vy:float;
func _physics_process(_delta: float) -> void:
	
	var maze : Maze = LiveDream.GetMaze(self)
	if maze :
		var cell = maze.local_to_map(position)
		if maze.get_cell_tid(cell) == 9:
			maze.set_cell_tid(cell, 19)
			var petals : CPUParticles2D = load(
				"res://dreamlands/why-did-i-do-it/rose_petals.tscn"
			).instantiate()
			petals.position = maze.map_to_center(cell)
			var room = LiveDream.GetRoom(self)
			room.add_child(petals)
			petals.lifetime = 2.3
			petals.owner = room.owner if room.owner else room
			petals.one_shot = true
			petals.restart()
			if !maze.get_used_cells_by_tids([9]):
				pending_escape(maze)
	
	var dpad = Pin.get_dpad()
	if dpad.x: spr.flip_h = dpad.x < 0
	if Pin.get_jump_hit(): bufs.on(JUMPBUF)
	if bufs.try_eat([JUMPBUF,FLORBUF]):
		vy = -1.0 #jump!
	var tofloor = mover.cast_fraction(self,caster,VERTICAL,1)
	var onfloor : bool = false
	if vy>=0 and tofloor<1:
		position.y += tofloor
		onfloor = true
	if onfloor: bufs.on(FLORBUF)
	vx = move_toward(vx,dpad.x*1.0,0.05)
	vy = move_toward(vy,3.0,0.03)
	if vx and!mover.try_slip_move(self,caster,HORIZONTAL,vx):
		vx = 0
	if vy and!mover.try_slip_move(self,caster,VERTICAL,vy):
		vy = 0
	if onfloor:
		if dpad.x:
			if len(spr.frames)!=4: match spr.frames[0]:
				20: spr.setup([21,30,31,20],5)
				30: spr.setup([31,20,21,30],5)
				10, _: spr.setup([20,21,30,31],5)
		else:
			spr.setup([10])
	else:
		var fwdvx : float = vx
		if spr.flip_h : fwdvx = -fwdvx
		if fwdvx < 0 or vy < -1: spr.setup([31])
		#elif fwdvx > 0: spr.setup([31])
		elif vy < 0: spr.setup([20])
		else: spr.setup([21])

func pending_escape(maze : Maze):
	var room_im_in = LiveDream.GetRoom(self)
	for i in range(4): room_im_in.room_links[i] = ''
	var why_rose_cells = maze.get_used_cells_by_tids([14,15,16,17,18])
	@warning_ignore("integer_division")
	var i1 = len(why_rose_cells)/2
	for i in range(i1): maze.set_cell_tid(why_rose_cells[i],-1)
	await get_tree().create_timer(1.0).timeout
	for i in range(i1,len(why_rose_cells)): maze.set_cell_tid(why_rose_cells[i],-1)
	await get_tree().create_timer(1.0).timeout
	hide()
	await get_tree().create_timer(0.5).timeout
	escape('rose')
