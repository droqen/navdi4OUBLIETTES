extends Node2D

@onready var chatter = $"../ChatterLabel"
@onready var chattogglearea = $"../ChatToggleArea"
var vx : float = 0
var vy : float = 0
func _ready() -> void:
	hide()
	chatter.doneprinting.connect(func():
		var player = NavdiSolePlayer.GetPlayer(self)
		if is_instance_valid(player):
			player.queue_free() # bye player
			position = player.position
			show()
		chattogglearea.disable_on_no_overlap = false
		chatter.printing = true
		chatter.zero_on_enter = false
		LiveDream.GetDream(self).windfish_lucidwake.emit("STAYED")
	)

func _physics_process(_delta: float) -> void:
	if position.y > -10 and visible:
		if randf() < 0.05:
			vx = randf_range(-.5,.5)
			if position.x < 20: vx += .25
			if position.x < 40: vx += .25
			if position.x > 150: vx -= .25
			if position.x > 170: vx -= .25
		vx *= 0.99
		vy *= 0.99
		vy -= 0.002
		position.x += vx * 0.25
		position.y += vy
