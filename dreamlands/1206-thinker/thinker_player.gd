extends NavdiSolePlayer

var vx : float = 0; var vy : float = 0;
var slidey : float = 0;
const FRMS = [ 10,14,15,16 ]

func _physics_process(_delta: float) -> void:
	var dpad = Pin.get_dpad();
	if dpad.x < 0 : vx = move_toward(vx,1,0.2)
	else: vx = move_toward(vx,-1,0.2)
	slidey += vx * 0.2
	if slidey < 0: slidey = 0
	if slidey >= len(FRMS): slidey = len(FRMS)-0.1
	$spr.setup([FRMS[int(slidey)]])
