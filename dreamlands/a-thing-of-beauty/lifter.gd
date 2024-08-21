extends Node
@onready var maze : Maze = get_parent()
var liftanim : int = 0
var liftframe : int = 0
func _physics_process(_delta: float) -> void:
	liftanim += 1
	if liftanim > 8: liftanim = 0; liftframe = (liftframe+1) % 4
	var player = NavdiSolePlayer.GetPlayer(self)
	var playercell : Vector2i = Vector2i(-1, -1)
	if player: playercell = maze.local_to_map(player.position)
	for liftercell in maze.get_used_cells_by_tids([28]):
		var targetcell = liftercell + Vector2i.UP
		var tid : int = [15,16,17,18,19][liftframe]
		while targetcell.y >= -1:
			if maze.is_cell_solid(targetcell): break
			else: maze.set_cell_tid(targetcell, tid)
			if targetcell == playercell:
				if player.vy > 0: player.vy *= 0.98
				player.vy -= 0.04
			targetcell.y -= 1
