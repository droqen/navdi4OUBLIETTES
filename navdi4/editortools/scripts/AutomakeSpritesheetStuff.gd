@tool
extends Node
class_name AutomakeSpritesheetStuff
@export var sprite_src : Texture2D
@export var tile_size : Vector2i = Vector2i(10, 10)
@export var click_to_automake : bool :
	get(): return false
	set(v): if v:
		if sprite_src:
			AutomakeSpritesheetStuff.Make(sprite_src, tile_size)
			sprite_src = null
			notify_property_list_changed()
#static func path_splice(path : String, add_suffix : String = "_test") -> String:
	#var path_split = path.rsplit(".",true,1)
	#if len(path_split) > 1:
		#return path_split[0] + add_suffix + path_split[1]
	#else:
		#return path + add_suffix
static var LastMakeResult_Sheet : Sheet
static var LastMakeResult_Tiles : TileSet
static func Make(raw : Texture2D, raw_tile_size : Vector2i):
	var path = raw.resource_path
	var sheet_path = path.replace(".png", "_sheet.tres")
	var tileset_path = path.replace(".png", "_tiles.tres")
	prints("trying to automake...", path, "sheet=", sheet_path, "tileset=", tileset_path)
	
	@warning_ignore("integer_division")
	var size_in_tiles : Vector2i = Vector2i(
		raw.get_width() / raw_tile_size.x,
		raw.get_height() / raw_tile_size.y
	)
	
	if !ResourceLoader.exists(sheet_path):
		var sheet = Sheet.new()
		sheet.texture = raw
		sheet.hframes = size_in_tiles.x
		sheet.vframes = size_in_tiles.y
		ResourceSaver.save(sheet, sheet_path)
	
	if !ResourceLoader.exists(tileset_path):
		var tileset = TileSet.new()
		tileset.add_physics_layer(0) # yes i want one physics layer
		tileset.tile_size = raw_tile_size
		var source = TileSetAtlasSource.new()
		source.texture = raw
		source.texture_region_size = raw_tile_size
		for y in range(size_in_tiles.y):
			for x in range(size_in_tiles.x):
				source.create_tile(Vector2i(x,y), Vector2i(1,1))
		tileset.add_source(source)
		ResourceSaver.save(tileset, tileset_path)
	
	AutomakeSpritesheetStuff.LastMakeResult_Sheet = ResourceLoader.load(sheet_path)
	AutomakeSpritesheetStuff.LastMakeResult_Tiles = ResourceLoader.load(tileset_path)
