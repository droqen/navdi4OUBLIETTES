extends Node
@onready var label : Label = get_parent()
@onready var player = NavdiSolePlayer.GetPlayer(self)
var revealing : bool = false
func _physics_process(delta: float) -> void:
	if !is_instance_valid(player) or player == null:
		if !revealing:
			# play song
			revealing = true
		label.visible_ratio += 1 * delta
		if label.visible_ratio >= 1:
			queue_free()
	
