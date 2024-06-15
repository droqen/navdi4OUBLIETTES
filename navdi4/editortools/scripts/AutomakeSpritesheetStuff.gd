@tool
extends Node
@export var sprite_src : Texture2D
@export var tile_size : Vector2i = Vector2i(10, 10)
@export var click_to_automake : bool :
	get(): return false
	set(v): if v:
		if sprite_src:
			var path = sprite_src.resource_path
			var sheet_path = path.replace(".png", "_sheet.tres")
			var tileset_path = path.replace(".png", "_tiles.tres")
			prints("trying to automake...", path, "sheet=", sheet_path, "tileset=", tileset_path)
			
			var size_in_tiles : Vector2i = Vector2i(
				sprite_src.get_width() / tile_size.x,
				sprite_src.get_height() / tile_size.y
			)
			
			if ResourceLoader.exists(sheet_path):
				prints("Automake failed - sheet already exists at",sheet_path)
			else:
				var sheet = Sheet.new()
				sheet.texture = sprite_src
				sheet.hframes = size_in_tiles.x
				sheet.vframes = size_in_tiles.y
				ResourceSaver.save(sheet, sheet_path)
			
			if ResourceLoader.exists(tileset_path):
				prints("Automake failed - tileset already exists at",tileset_path)
			else:
				var tileset = TileSet.new()
				tileset.add_physics_layer(0) # yes i want one physics layer
				tileset.tile_size = tile_size
				var source = TileSetAtlasSource.new()
				source.texture = sprite_src
				source.texture_region_size = tile_size
				for y in range(size_in_tiles.y):
					for x in range(size_in_tiles.x):
						source.create_tile(Vector2i(x,y), Vector2i(1,1))
				tileset.add_source(source)
				ResourceSaver.save(tileset, tileset_path)
			
			sprite_src = null
func path_splice(path : String, add_suffix : String = "_test") -> String:
	var path_split = path.rsplit(".",true,1)
	if len(path_split) > 1:
		return path_split[0] + add_suffix + path_split[1]
	else:
		return path + add_suffix
