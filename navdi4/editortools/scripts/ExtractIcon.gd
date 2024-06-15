@tool
extends Node
@export var sheet : Sheet
@export var exporticon : Texture2D
var _frame : int = 0
@export var frame : int :
	get(): return _frame
	set(v): if _frame != v:
		if sheet and sheet.hframes and sheet.vframes:
			_frame = posmod(v, sheet.hframes * sheet.vframes)
			var sheet_image : Image = sheet.texture.get_image()
			var sheet_cell_width : int = floori(sheet.texture.get_width() / sheet.hframes)
			var sheet_cell_height : int = floori(sheet.texture.get_height() / sheet.vframes)
			exporticon = ImageTexture.create_from_image(sheet_image.get_region(Rect2i(
				(_frame % sheet.hframes) * sheet_cell_width,
				floori(_frame / sheet.hframes) * sheet_cell_height,
				sheet_cell_width,
				sheet_cell_height,
			)))
			notify_property_list_changed()
@export var click_to_save : bool :
	get(): return false
	set(v): if v:
		if exporticon:
			var scale : int = maxi(1, floori(128.0 / exporticon.get_width()))
			var iconimage = exporticon.get_image();
			iconimage.resize(
				exporticon.get_width() * scale,
				exporticon.get_height() * scale,
				Image.INTERPOLATE_NEAREST
			)
			prints("saving iconimage of size ",iconimage.get_width(),'x',iconimage.get_height(),':',
				iconimage.save_png("res://icon.png"))
			sheet = null
			exporticon = null
		else:
			print("no exporticon")
