@tool
extends Node
class_name AutomakeIcon2

static func MakeSave(sheet:Sheet, frame:int):
	if sheet and sheet.hframes and sheet.vframes:
		frame = posmod(frame, sheet.hframes * sheet.vframes)
		var sheet_image : Image = sheet.texture.get_image()
		@warning_ignore("integer_division")
		var sheet_cell_width : int = floori(sheet.texture.get_width() / sheet.hframes)
		@warning_ignore("integer_division")
		var sheet_cell_height : int = floori(sheet.texture.get_height() / sheet.vframes)
		@warning_ignore("integer_division")
		var iconimagetexture : ImageTexture = ImageTexture.create_from_image(sheet_image.get_region(Rect2i(
			(frame % sheet.hframes) * sheet_cell_width,
			floori(frame / sheet.hframes) * sheet_cell_height,
			sheet_cell_width,
			sheet_cell_height,
		)))
		var iconimage = iconimagetexture.get_image()
		var scale : int = maxi(1, floori(128.0 / sheet_cell_width))
		iconimage.resize(
			sheet_cell_width * scale,
			sheet_cell_height * scale,
			Image.INTERPOLATE_NEAREST
		)
		prints("saving iconimage of size ",iconimage.get_width(),'x',iconimage.get_height(),':',
			iconimage.save_png("res://icon.png"))
