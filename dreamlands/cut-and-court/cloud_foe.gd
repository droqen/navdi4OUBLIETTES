extends Node2D

func take_damage() -> void:
	queue_free()
	var any_enemies_remaining : bool = false
	for enemy in get_tree().get_nodes_in_group("CutCourtEnemy"):
		if enemy == self: continue
		any_enemies_remaining = true; break
	var maze : Maze = LiveDream.GetMaze(self)
	if maze:
		var spikes_clearer = load(
			"res://dreamlands/cut-and-court/^clear_all_spikes.gd"
		).new(!any_enemies_remaining)
		maze.add_child(spikes_clearer)
		spikes_clearer.owner = maze.owner if maze.owner else maze
		print("added")
