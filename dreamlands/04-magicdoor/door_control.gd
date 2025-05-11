extends Node

func change_tid_keeping_flipdata(
cell:Vector2i,tid:int)->void:
	var maze : Maze = $"../Maze"
	var alt_tile = maze.get_cell_alternative_tile(cell)
	var flip_h = alt_tile & TileSetAtlasSource.TRANSFORM_FLIP_H > 0
	maze.set_cell_tid(cell, tid, 
	TileSetAtlasSource.TRANSFORM_FLIP_H
		if flip_h else 0)

@export var kills_th_player : bool = false
@export_range(0,4) var starting_openness = 0

var _openness_index : int = -1
var openness_index : int :
	get : return _openness_index
	set (v) :
		if _openness_index != v:
			_openness_index = v
			var maze : Maze = $"../Maze"
			for oi in range(len(DOOR_OFFSETS)):
				var tids : Array[int] = []
				for ti in range(len(DOOR_TILES)):
					tids.append(DOOR_TILES[ti]+DOOR_OFFSETS[oi])
				for cell in maze.get_used_cells_by_tids(tids):
					change_tid_keeping_flipdata(cell, DOOR_TILES[openness_index] + DOOR_OFFSETS[oi])
const DOOR_TILES = [78,76,74,72,70]
const DOOR_OFFSETS = [0, 1, 10, 11, 20, 21]

var ani : int = 0
var anidir : int = 1
var firsttime : bool = true

func _ready() -> void:
	openness_index = starting_openness
	if openness_index == 4: anidir = -1
	elif has_node("Label"): $Label.hide()
	starting_openness = 0

func _enter_tree() -> void:
	if firsttime:
		firsttime = false
	else:
		openness_index = 0
		ani = -20
		anidir = 1

func _physics_process(_delta: float) -> void:
	ani += 1
	var playerr = NavdiSolePlayer.GetPlayer(self)
	var player_in_area : bool = (
		playerr.position.x > 10 and
		playerr.position.x < 90)
	
	if ani >= 10:
		ani = 0
		if not player_in_area: anidir = -1
		openness_index = clampi(openness_index + anidir, 0, 4)
	var player_inside_door : bool = false
	var player_arears = $player_area.get_overlapping_areas()
	if player_arears:
		var player = player_arears[0].get_parent()
		if player is NavdiSolePlayer:
			if player.bufs.has(player.FLORBUF) and player.vx == 0 and player.vy == 0:
				player_inside_door = true
	if player_inside_door:
		if anidir > 0:
			ani = 0
			anidir = -1
		if openness_index <= 1:
			$Blackout.show()
			playerr.position.x = 50
			if kills_th_player:
				playerr.escape(0)
		else:
			$Blackout.hide()
	elif player_in_area:
		if $Blackout.visible and openness_index < 2:
			openness_index = 2
		anidir = 1
		$Blackout.hide()
	else:
		anidir = -1
		$Blackout.hide()
	
	if has_node("Label"):
		$Label.visible = $Blackout.visible
	playerr.visible = !$Blackout.visible
