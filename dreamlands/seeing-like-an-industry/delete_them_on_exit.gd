extends Node

func _exit_tree() -> void:
	for child in get_parent().get_children():
		if "them" in child.name:
			child.queue_free()
