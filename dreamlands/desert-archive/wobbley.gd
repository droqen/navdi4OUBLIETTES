extends Node2D

@onready var startpos : Vector2 = position

var wa : float = 0.0
var we : float = 0.0
var wi : float = 0.0

func _ready() -> void:
	wa = randi()
	we = randi()
	wi = randi()

func _physics_process(_delta: float) -> void:
	wa += 0.01104
	we += 0.00921
	wi += 0.00341
	rotation = 0.01 * sin(wa)
	position.x = startpos.x + 2 * sin(we)
	position.y = startpos.y + 7 * sin(wi)
