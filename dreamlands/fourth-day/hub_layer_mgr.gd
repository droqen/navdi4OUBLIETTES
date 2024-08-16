extends Node2D

@export var orbs_collected : int = 2

func _enter_tree() -> void:
	for layer in get_children(): layer.enabled = false
	match orbs_collected:
		0,1,2: $Dirt012.enabled = true
		3,4: $Dirt34.enabled = true
	match orbs_collected:
		0: $Tree0.enabled = true
		1: $Tree1.enabled = true
		2: $Tree2.enabled = true
		#3: $Tree3.enabled = true
