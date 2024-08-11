@tool
extends Resource
class_name NavdiCart

const MONTHS = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

@export var name : String = 'unmarked'
@export var play_script : GDScript
@export var game_size : Vector2i = Vector2i(180, 200)
@export var view_scale : Vector2i = Vector2i(2, 2)
@export var bg_transparent : bool = false
@export var bg_colour : Color = Color("#d45455")
@export var pixelated : bool = true
@export_category("Birth Date")
@export var prepend_date : bool = true
func autofill_birth_today() -> void:
	var now = Time.get_datetime_dict_from_system()
	prints(now)
	birth_year = now.year
	birth_month = MONTHS[now.month-1]
	birth_day = now.day
	notify_property_list_changed()
@export var birth_year : int = 0
@export var birth_month : String = "?"
@export var birth_day : int = 0

@export var sheet_src : Texture2D
@export var tile_size : Vector2i = Vector2i(10, 10)
@export var icon_idx : int = 9 # default: top right = game icon

func apply_changes(main : Node2D) -> void:
		if prepend_date:
			setting("application/config/name",
				"%d, %s %s ~ %s" %
					[birth_year, birth_month, stndth(birth_day), name])
		else:
			setting("application/config/name", name)
		
		setting("application/run/main_scene",
			main.scene_file_path)
		setting("display/window/size/viewport_width",
			maxi(1,game_size.x))
		setting("display/window/size/viewport_height",
			maxi(1,game_size.y))
		setting("display/window/size/window_width_override",
			maxi(1,game_size.x * view_scale.x))
		setting("display/window/size/window_height_override",
			maxi(1,game_size.y * view_scale.y))
		setting("display/window/stretch/mode",
			"viewport")
		setting("display/window/stretch/aspect",
			"ignore")
		setting("display/window/size/transparent",
			bg_transparent)
		setting("display/window/per_pixel_transparency/allowed",
			bg_transparent)
		setting("rendering/viewport/transparent_background",
			bg_transparent)
		setting("rendering/environment/defaults/default_clear_color",
			bg_colour)
		setting("application/boot_splash/bg_color",
			bg_colour)
		setting("application/boot_splash/fullsize", false)
		if pixelated:
			setting("rendering/2d/snap/snap_2d_transforms_to_pixel", true)
			setting("rendering/2d/snap/snap_2d_vertices_to_pixel", true)
			main.texture_filter = main.TEXTURE_FILTER_NEAREST
		else:
			setting("rendering/2d/snap/snap_2d_transforms_to_pixel", false)
			setting("rendering/2d/snap/snap_2d_vertices_to_pixel", false)
			if main.texture_filter == main.TEXTURE_FILTER_NEAREST:
				main.texture_filter = main.TEXTURE_FILTER_LINEAR
		
		notify_property_list_changed()
		ProjectSettings.notify_property_list_changed()
		ProjectSettings.save()
		
		print("cart changes applied!")

func stndth(number : int) -> String:
	if number <= 0: return str(number)
	else: match number % 10:
		1: return str(number) + "st"
		2: return str(number) + "nd"
		_: return str(number) + "th"

func setting(settingname : String, value):
	ProjectSettings.set_setting(settingname, value)
