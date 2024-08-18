extends NavdiSolePlayer
enum {FLORBUF,JUMPBUF,ONWALLBUF,WALLJUMPEDBUF}
var bufs = Bufs.Make(self).setup_bufons(
	[FLORBUF,5,JUMPBUF,7,ONWALLBUF,4,WALLJUMPEDBUF,10]
)
var onwall : bool
var lastonwalldir : int = 0
var walljumpeddir : int = 0
var vx : float; var vy : float;
var onfloor : bool
var nocrawl_release : bool
var crawling : bool
var tunneling : bool
var tunneling_start_cell : Vector2i
var tunneling_patience : int = 0
func _physics_process(_delta: float) -> void:
	var room = LiveDream.GetRoom(self)
	var maze : Maze
	if room : maze = room.maze
	var dpad = Pin.get_dpad()
	
	if not room or not maze:
		tunneling = false
	
	if tunneling:
		if tunneling_patience <= 0 or not Pin.get_plant_held():
			var goingtocell = maze.local_to_map(position + Vector2(dpad.x*3,0))
			if not maze.is_cell_solid(goingtocell):
				tunneling_start_cell = goingtocell
			
			var tunneling_start_pos = maze.map_to_local(tunneling_start_cell)
			var to_start_pos = tunneling_start_pos - position
			if abs(to_start_pos.x) < 1:
				tunneling = false
				crawling = false; nocrawl_release = true;
				position.x = maze.map_to_local(tunneling_start_cell).x
				vy = -0.8 # i'm free!
				#dpad.x = 0
			else:
				dpad.x = 2 * sign(to_start_pos.x)
		else:
			tunneling_patience -= 1
			if tunneling_patience < 30: dpad.x = 0
		if dpad.x:
			var tunnelcastpoint = position + Vector2(dpad.x * 3, 0)
			var tunnelcastcell = maze.local_to_map(tunnelcastpoint)
			var oktomove : bool;
			match [
				maze.is_cell_solid(tunnelcastcell),
				maze.get_cell_tid(tunnelcastcell)
			]:
				[false,_]: oktomove = true
				[true,2],[true,3]: oktomove = true
				[true,_]: oktomove = false
			if oktomove: position.x += dpad.x * 0.2
	else:
		if dpad.x : $spr.flip_h = dpad.x < 0 
		if Pin.get_jump_hit() : bufs.on(JUMPBUF)
		onfloor = vy >= 0 and $mover.cast_fraction(self, $mover/solidcast, VERTICAL, 1) < 1
		onwall = false
		if (dpad.x and not onfloor and
			$mover.cast_fraction(self, $mover/solidcast, HORIZONTAL, dpad.x) < 1):
				onwall = true
				lastonwalldir = dpad.x
				bufs.on(ONWALLBUF)
		if onfloor: bufs.on(FLORBUF)
		if onfloor or onwall: walljumpeddir = 0
		if bufs.try_eat([FLORBUF,JUMPBUF]):
			vy = -1.5
		if bufs.try_eat([ONWALLBUF,JUMPBUF]):
			vy = -1.5
			walljumpeddir = -lastonwalldir
			vx = walljumpeddir * 1.5
			bufs.on(WALLJUMPEDBUF)
		if nocrawl_release and Pin.get_plant_hit():
			nocrawl_release = false
		if crawling != (onfloor and Pin.get_plant_held()) and not nocrawl_release and maze:
			if crawling and Pin.get_plant_held() and maze.get_cell_tid(maze.local_to_map(position)+Vector2i.DOWN) == 4:
				pass # stay crawling! you're on a bridge
			else:
				crawling = not crawling
				if not crawling: vy = -0.8 # hop
		if crawling:
			vx = move_toward(vx,dpad.x * 0.4, 0.2)
			vy = 0.0
		else:
			vx = move_toward(vx,dpad.x, 0.2)
			vy = move_toward(vy, 2.0, 0.1)
			if onwall and vy > 0: vy *= 0.9
		if not $mover.try_slip_move(self, $mover/solidcast, HORIZONTAL, vx):
			if vx and crawling and maze:
				tunneling = true
				tunneling_patience = 90 + randi() % 24
				tunneling_start_cell = maze.local_to_map(self.position)
				return;
			vx = 0
		if not $mover.try_slip_move(self, $mover/solidcast, VERTICAL, vy):
			if vy > 0:
				vy = 0
	
	if crawling: # and floor
		if dpad.x:
			match [$spr.frames.size(), $spr.frames[0]]:
				[1,20]: $spr.setup([21,20],19)
				[1,_],[4,_]: $spr.setup([20,21],19)
		else: $spr.setup([20])
	elif onfloor:
		if dpad.x:
			match [$spr.frames.size(), $spr.frames[0]]:
				[1,10]: $spr.setup([11,12,13,14],8)
				[1,13]: $spr.setup([14,11,12,13],8)
				[1,_],[2,_]: $spr.setup([12,13,14,11],8)
		else: $spr.setup([10])
	elif onwall and vy > 0:
		$spr.setup([22])
	else:
		var fwdvx : float = vx * (-1 if $spr.flip_h else 1)
		if fwdvx > 0.75: $spr.setup([11])
		else: $spr.setup([13])
