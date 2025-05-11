extends Node

func change_tid_keeping_flipdata(
cell:Vector2i,tid:int)->void:
	var maze : Maze = $"../Maze"
	var alt_tile = maze.get_cell_alternative_tile(cell)
	var flip_h = alt_tile & TileSetAtlasSource.TRANSFORM_FLIP_H > 0
	maze.set_cell_tid(cell, tid, 
	TileSetAtlasSource.TRANSFORM_FLIP_H
		if flip_h else 0)

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
const DOOR_TILES = [70, 72, 74, 76, 78]
const DOOR_OFFSETS = [0, 1, 10, 11, 20, 21]

var ani : int = 0
var anidir : int = 1

func _ready() -> void:
	openness_index = starting_openness
	if openness_index == 4: anidir = -1

func _physics_process(_delta: float) -> void:
	ani += 1
	if ani >= 10:
		ani = 0
		openness_index += anidir
		if openness_index == 4: anidir = -1; ani = -20
		if openness_index == 0: anidir = 1; ani = -20
