extends NavdiSolePlayer

var vx:float;var vy:float;
enum{FLORBUF,JUMPBUF,LANDBUF,STUNNEDBUF,}
@onready var bufs:Bufs=Bufs.Make(self).setup_bufons(
	[FLORBUF,4,JUMPBUF,4,LANDBUF,5,STUNNEDBUF,20,]
)
@onready var spr = $spr
@onready var mover = $mover
@onready var cast = $mover/cast
var score_broken : bool = false
var scoring : bool = false
var score : int = -3
func _ready() -> void:
	super._ready()
	travelled_dir.connect(func(dir):if not bufs.has(FLORBUF):scoring=true)
func _physics_process(_delta: float) -> void:
	if frozen:
		frozen_dur -= 1
		if frozen_dur <= 0 and is_inside_tree():
			LiveDream.GetDream(self).windfish_awakened.emit()
			deplayer()
		return
	
	var maze : Maze = LiveDream.GetMaze(self)
	var dpad = Pin.get_dpad()
	var fly = Pin.get_jump_held()
	if maze:
		match maze.get_cell_tid(maze.local_to_map(position)):
			17:
				hide()
			27,-1:
				show()
				fly = false
			37:
				show()
				if fposmod(position.y,10)<5: fly = false
			_:
				show()
	if bufs.has(STUNNEDBUF):
		dpad*=0
		fly=false
	var onfloor:bool=vy>=0 and mover.cast_fraction(
		self,cast,VERTICAL,1
	)<1
	if onfloor:
		if not bufs.has(FLORBUF): bufs.on(LANDBUF)
		bufs.on(FLORBUF)
		if Pin.get_plant_held() and dpad.x == 0:
			bufs.on(LANDBUF)
		scoring = false
		score = -3
		$score.hide()
	else:
		if score_broken:
			$score/Label.text = "###"
			$score.show()
		elif scoring:
			if dpad.x or fly:
				score += 1
			if score > 0:
				if int(score*0.1) > 999:
					if !score_broken:
						score_broken = true
				else:
					$score/Label.text = "%03d" % int(score*0.1)
					$score.show()
		else:
			score = -3
			$score.hide()
	
	if fly:
		vy -= min(0.05, 0.20 * abs(vx) - 0.04)
		if vy > 2.0: vy = 2.0
		if vy < -1.0:
			vy *= 0.95
			if dpad.x == 0 and vx:
				vy -= abs(vx) * 0.05
		if onfloor and vy > -0.2: vy = -0.8
	else:
		vy = move_toward(vy,2.0,0.04)
	if (onfloor or fly) and dpad.x:
		if fly and abs(vx)>=1.0:
			vx = move_toward(vx,dpad.x*2.0,0.02)
		else:
			vx = move_toward(vx,dpad.x*1.0,0.07)
	else:
		vx = move_toward(vx*0.99,dpad.x*1.0,0.01)
	
	if vx and!mover.try_slip_move(self,cast,HORIZONTAL,vx):
		if scoring:
			scoring = false
			vx *= -0.5
			bufs.on(STUNNEDBUF)
		else:
			vx = 0
	if vy and!mover.try_slip_move(self,cast,VERTICAL,vy):
		if scoring:
			scoring = false
			vx *= 0.8
			vy *= -0.5
			bufs.on(STUNNEDBUF)
		else:
			vy = 0
	
	if dpad.x: spr.flip_h = dpad.x < 0
	
	if onfloor:
		if bufs.has(LANDBUF):
			spr.setup([8])
		elif dpad.x:
			spr.setup([9,1,2,3],8)
		else:
			spr.setup([9,1,2,3],16)
	else:
		if vy < -1:
			spr.setup([4,6],6)
		elif vy < 0 and dpad.x:
			spr.setup([4,5,6,7],8)
			score += 1
		elif vy > 0 and fly:
			spr.setup([7,9],4)
			score += 1
		else:
			spr.setup([9,1,2,3],8)
	
var frozen : bool = false
var frozen_dur : int = 100
	
func _on_area_2d_area_entered(_area: Area2D) -> void:
	vy = 0
	frozen = true
	hide()
