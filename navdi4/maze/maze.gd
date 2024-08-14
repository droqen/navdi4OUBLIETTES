@tool
extends TileMapLayer
class_name Maze

const SOLE_SOURCE_ID = 0
const SOLE_COLLISION_LAYER = 0
const SOLE_NAVIGATION_LAYER = 0

var tidkey_initialized : bool = false
var dict_tids_physlayers : Array[Dictionary]
var tile_src : TileSetAtlasSource = null
var tile_src_w : int = 0

@export var hide_on_play : bool = false

func _ready():
	if not Engine.is_editor_hint():
		_require_tidkey()
		if hide_on_play: hide()

func _require_tidkey():
	if not tidkey_initialized:
		tidkey_initialized = true # don't call this again ever!
		if tile_set==null:push_error("maze has no tileset");return false;
		tile_src = tile_set.get_source(SOLE_SOURCE_ID) as TileSetAtlasSource
		if tile_src==null:push_error("maze's tileset has no src");return false;
		tile_src_w = tile_src.get_atlas_grid_size().x
		dict_tids_physlayers.clear()
		var physlayer_count : int = tile_set.get_physics_layers_count()
		var physlayer_range = range(physlayer_count)
		for i in physlayer_range:
			dict_tids_physlayers.append(Dictionary())
		for tid in range(tile_src.get_tiles_count()):
			var tile_data : TileData = tile_src.get_tile_data(tid2coord(tid), 0)
			if tile_data:
				for i in physlayer_range:
					if tile_data.get_collision_polygons_count(i) > 0:
						dict_tids_physlayers[i][tid] = true
		return true

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		navigation_enabled = false # no navigation.
		if tile_set and tile_set.get_source_count() > 0:
			tile_set.set_source_id(tile_set.get_source_id(0), SOLE_SOURCE_ID)

func tid2coord(tid:int)->Vector2i:
	_require_tidkey()
	if tid < 0: return Vector2(-1,-1)
	@warning_ignore("integer_division")
	return Vector2i(tid%tile_src_w,tid/tile_src_w)
func coord2tid(atlas_coord:Vector2i)->int:
	_require_tidkey()
	if atlas_coord.x < 0: return -1
	return atlas_coord.x+atlas_coord.y*tile_src_w

func set_cell_tid(maze_coords:Vector2i, tid:int):
	_require_tidkey()
	set_cell(maze_coords, SOLE_SOURCE_ID, tid2coord(tid))
	changed.emit()

func get_cell_tid(maze_coords:Vector2i) -> int:
	_require_tidkey()
	return coord2tid(get_cell_atlas_coords(maze_coords))

func is_cell_solid(maze_coords:Vector2i, physlayer_index:int = 0) -> bool:
	_require_tidkey()
	return dict_tids_physlayers[physlayer_index].has(get_cell_tid(maze_coords))

func map_to_center(maze_coords:Vector2i) -> Vector2:
	return map_to_local(maze_coords) #+ (tile_set.tile_size as Vector2 * 0.5)

func get_used_cells_by_tids(tids : Array[int]) -> Array[Vector2i]:
	var used_cells : Array[Vector2i] = []
	for tid in tids:
		used_cells.append_array(get_used_cells_by_id(0, tid2coord(tid)))
	return used_cells

const DIRS = [Vector2i.RIGHT,Vector2i.UP,Vector2i.LEFT,Vector2i.DOWN,]

func magic_wand(start : Vector2i, verifier : Callable) -> Array[Vector2i]:
	var cells : Array[Vector2i] = [start]
	var excluded_cells : Array[Vector2i] = []
	var i : int = 0
	while i < len(cells):
		for dir in DIRS:
			var cell2 = cells[i] + dir
			if cells.has(cell2): continue
			if excluded_cells.has(cell2): continue
			if verifier.call(cell2): cells.append(cell2)
			else: excluded_cells.append(cell2)
		i += 1
	return cells
