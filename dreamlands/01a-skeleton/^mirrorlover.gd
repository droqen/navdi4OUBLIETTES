extends Node

func _enter_tree() -> void:
	var p = get_parent()
	var pReal = NavdiSolePlayer.GetPlayer(self)
	p.position = pReal.position
	p.position.x -= 70
	p.vx = pReal.vx
	p.vy = pReal.vy
	p.faceleft = pReal.faceleft
	p.get_node("spr").flip_h = p.faceleft

func _physics_process(_delta: float) -> void:
	var p = get_parent()
	if !p.nograv:
		var pReal = NavdiSolePlayer.GetPlayer(self)
		if pReal.position.x < 70:
			pReal.position.x += 70
		p.position.x = pReal.position.x - 70
		p.position.y = pReal.position.y
