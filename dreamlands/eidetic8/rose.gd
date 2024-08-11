extends Label

@export var colour_btm : Color
@export var colour_top : Color

var vy : float = 0.0

@onready var startpos = position
@onready var bottom = startpos.y
@onready var top = bottom - 141

func _physics_process(_delta: float) -> void:
	vy = lerp(vy, -0.1, 0.01)
	position.y += vy
	modulate = lerp(
		colour_btm,
		colour_top,
		clamp(inverse_lerp(bottom-10, top+10, position.y), 0, 1)
	)
	if position.y < top:
		position.y = bottom; vy = 0
