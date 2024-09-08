extends Node2D
@export var xperiod : int = 200
@export var xamp : float = 8.0
@export var yperiod : int = 343
@export var yamp : float = 4.0

var _p : Vector2
var _t : int
func _ready() -> void:
	_p = position
	_t = randi()
	_physics_process(0)
func _physics_process(_delta: float) -> void:
	_t += 1
	position = _p + Vector2(
		posmod(_t,xperiod)/float(xperiod) * xamp,
		posmod(_t,yperiod)/float(yperiod) * yamp 
	)
	
