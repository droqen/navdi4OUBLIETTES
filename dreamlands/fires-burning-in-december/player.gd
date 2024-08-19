extends NavdiSolePlayer
var vx : float; var vy : float;
func _physics_process(_delta: float) -> void:
	var dpad = Pin.get_dpad()
	var spr : SheetSprite = $SheetSprite
	var mover : NavdiBodyMover = $NavdiBodyMover
	var caster : ShapeCast2D = $NavdiBodyMover/ShapeCast2D
	
	vx = move_toward(vx, dpad.x * 1.1, 0.1)
	vy = move_toward(vy, 1.5, 0.046)
	
	if vx and not mover.try_slip_move(self, caster, HORIZONTAL, vx):
		vx = 0
	if vy and not mover.try_slip_move(self, caster, VERTICAL, vy):
		vy = 0
	
	var floor = vy >= 0 and mover.cast_fraction(self, caster, VERTICAL, 1) < 1
	#if position.y + vy > 145:
		#position.y = 145
		#vy = 0
		#floor = true
	if floor and Pin.get_jump_hit(): floor = false; vy = -1.5
	
	var maze = LiveDream.GetMaze(self)
	if maze: match maze.get_cell_tid(maze.local_to_map(position)):
		3: escape(maze.get_parent().name)
