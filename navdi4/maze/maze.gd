@tool
extends TileMapLayer
class_name Maze

const SOLE_SOURCE_ID = 0
const SOLE_COLLISION_LAYER = 0
const SOLE_NAVIGATION_LAYER = 0

var tidkey_initialized : bool = false
var dict_tids_navigable : Dictionary
var tile_src : TileSetAtlasSource = null
var tile_src_w : int = 0

func _ready():
	if not Engine.is_editor_hint(): _require_tidkey()

func _require_tidkey():
	if not tidkey_initialized:
		if tile_set==null:push_error("maze has no tileset");return false;
		tile_src = tile_set.get_source(SOLE_SOURCE_ID) as TileSetAtlasSource
		if tile_src==null:push_error("maze's tileset has no src");return false;
		tile_src_w = tile_src.get_atlas_grid_size().x
		dict_tids_navigable.clear()
		var has_nav_layers : bool = tile_set.get_navigation_layers_count() > 0
		if has_nav_layers: for tid in range(tile_src.get_tiles_count()):
			var tile_data : TileData = tile_src.get_tile_data(tid2coord(tid), 0)
			if tile_data and tile_data.get_navigation_polygon(SOLE_NAVIGATION_LAYER):
				dict_tids_navigable[tid] = true
		tidkey_initialized = true # done!
		return true

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		navigation_enabled = false # no navigation.
		if tile_set and tile_set.get_source_count() > 0:
			tile_set.set_source_id(tile_set.get_source_id(0), SOLE_SOURCE_ID)

func tid2coord(tid:int)->Vector2i:
	if tid < 0: return Vector2(-1,-1)
	@warning_ignore("integer_division")
	return Vector2i(tid%tile_src_w,tid/tile_src_w)
func coord2tid(atlas_coord:Vector2i)->int:
	if atlas_coord.x < 0: return -1
	return atlas_coord.x+atlas_coord.y*tile_src_w

func set_cell_tid(maze_coords:Vector2i, tid:int):
	_require_tidkey()
	set_cell(maze_coords, SOLE_SOURCE_ID, tid2coord(tid))

func get_cell_tid(maze_coords:Vector2i) -> int:
	_require_tidkey()
	return coord2tid(get_cell_atlas_coords(maze_coords))

func is_cell_navigable(maze_coords:Vector2i) -> bool:
	_require_tidkey()
	return dict_tids_navigable.has(get_cell_tid(maze_coords))

func map_to_center(maze_coords:Vector2i) -> Vector2:
	return map_to_local(maze_coords) #+ (tile_set.tile_size as Vector2 * 0.5)
