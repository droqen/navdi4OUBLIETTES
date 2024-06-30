extends Node2D

@onready var startpos = position
var jewel = null
var opening : bool = false

func _enter_tree() -> void:
	if startpos != null:
		if opening:
			position.y = startpos.y + 30.1
		else:
			position.y = startpos.y

func _physics_process(_delta: float) -> void:
	if jewel and is_instance_valid(jewel):
		jewel.position.x = move_toward(jewel.position.x, $jewel_detector.global_position.x, 0.5)
		opening = true
	else:
		if $cant_close_detector.get_overlapping_areas():
			opening = true
		else:
			opening = false
		for area in $jewel_detector.get_overlapping_areas():
			if area.get_parent().get('is_jewel'):
				jewel = area.get_parent()
	
	if opening:
		position.y = move_toward(position.y, startpos.y + 30.1, 0.1)
	else:
		position.y = move_toward(position.y, startpos.y, 0.1)
		
