extends Node

@export var lovers : Array[Node2D]
var fallen_lover : Node2D = null

func _physics_process(_delta: float) -> void:
	if fallen_lover:
		for lover in lovers:
			if lover != fallen_lover:
				if lover.position.x < 0: lover.position.x += 140
				if lover.position.x > 140: lover.position.x -= 140
				if lover.position.y < 0:
					LiveDream.GetDream(self).player_escaped.emit(0)
	else:
		for lover in lovers:
			if lover.position.y > 140:
				fallen_lover = lover
