@tool
extends Node2D
class_name NavdiMain

const MONTHS = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

@export var setup_button : bool :
	set(v) : if v :
		if prepend_date:
			setting("application/config/name",
				"%d, %s %s ~ %s" %
					[time_year, time_month, stndth(time_day), game_name])
		else:
			setting("application/config/name", game_name)
		
		setting("application/run/main_scene",
			scene_file_path)
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
		setting("rendering/environment/defaults/default_clear_color",
			bg_colour)
		setting("application/boot_splash/bg_color",
			bg_colour)
		setting("application/boot_splash/image",
			icon.resource_path if icon else '')
		setting("application/config/icon",
			icon.resource_path if icon else '')
		setting("application/boot_splash/fullsize", false)
		if pixelated:
			setting("rendering/2d/snap/snap_2d_transforms_to_pixel", true)
			setting("rendering/2d/snap/snap_2d_vertices_to_pixel", true)
			texture_filter = TEXTURE_FILTER_NEAREST
		
		notify_property_list_changed()
		ProjectSettings.notify_property_list_changed()
		ProjectSettings.save()
		
		print("changes to ProjectSettings saved!")

@export var game_name : String = "void"
@export var game_size : Vector2i = Vector2i(180, 200)
@export var view_scale : Vector2i = Vector2i(2, 2)
@export var icon : Texture2D
@export var bg_colour : Color = Color("#d45455")
@export var pixelated : bool = true
@export_category("Today's Date")
@export var prepend_date : bool = true
@export var autofill_today_button : bool :
	set(v):if v:
		var now = Time.get_datetime_dict_from_system()
		prints(now)
		time_year = now.year
		time_month = MONTHS[now.month-1]
		time_day = now.day
		notify_property_list_changed()
@export var time_year : int = 0
@export var time_month : String = "?"
@export var time_day : int = 0

func stndth(number : int) -> String:
	if number <= 0: return str(number)
	else: match number % 10:
		1: return str(number) + "st"
		2: return str(number) + "nd"
		_: return str(number) + "th"

func setting(settingname : String, value):
	ProjectSettings.set_setting(settingname, value)

var screenshotting_enabled = false

func _ready() -> void:
	if texture_filter != TEXTURE_FILTER_NEAREST and pixelated:
		texture_filter = TEXTURE_FILTER_NEAREST
		notify_property_list_changed()
	if not Engine.is_editor_hint():
		
		var Cat = JavaScriptBridge.get_interface('Cat')
		if Cat:
			print("Cat found!")
			Cat.set_game_size(
				ProjectSettings.get_setting("display/window/size/viewport_width"),
				ProjectSettings.get_setting("display/window/size/viewport_height")
			)
			$LiveDream.windfish_awakened.connect(
				func(): Cat.on_windfish_awakened()
			)
		else:
			print("Cat not found - You do not have access to JS")
		
		if OS.has_feature("editor"):
			screenshotting_enabled = true
			print("framecapture tool enabled.")
		

# TODO - this should all be in a separate node

@export_category("Editor-Export Gif Capture")
@export var gcap_enabled : bool = true
@export var gcap_max_dur : int = 120
@export var gcap_frmdelay : int = 0
@export var gcap_startkey : Key = KEY_4
@export var gcap_stopkey : Key = KEY_5

var gif_capturing : bool = false
var gif_capture_label : String = ''
var gif_capture_frameindex : int = 0
var _gif_capture_frm_delay_buf : int = 0

func _physics_process(_delta: float) -> void:
	if screenshotting_enabled and gcap_enabled:
		if gif_capturing:
			if gif_capture_frameindex <= gcap_max_dur:
				if _gif_capture_frm_delay_buf > 0:
					_gif_capture_frm_delay_buf -= 1
				else:
					if gif_capture_frameindex % 10 == 0:
						print("[f%4d] of [%s]" % [gif_capture_frameindex, gif_capture_label])
					get_viewport().get_texture().get_image().save_png("captures/%s/%04d.png" % [gif_capture_label, gif_capture_frameindex])
					gif_capture_frameindex += 1
					_gif_capture_frm_delay_buf = gcap_frmdelay
			elif not Input.is_key_pressed(gcap_startkey):
				gif_capturing = false
			if Input.is_key_pressed(gcap_stopkey):
				gif_capturing = false
			
			if gif_capturing == false:
				print("finished.. [%s]" % gif_capture_label)
		else:
			if Input.is_key_pressed(gcap_startkey):
				gif_capturing = true
				gif_capture_frameindex = 0
				var now = Time.get_datetime_dict_from_system()
				#Returns the current date as a dictionary of keys: year, month, day,
				#weekday, hour, minute, second, and dst (Daylight Savings Time).
				gif_capture_label = "%04d%02d%02d-%02d-%02d-%02d" % [
					now['year'],now['month'] ,now['day'],
					now['hour'],now['minute'],now['second'],
				]
				DirAccess.make_dir_recursive_absolute("captures/%s"%gif_capture_label)
				var _gdignore_file = FileAccess.open("captures/.gdignore", FileAccess.WRITE)
				print("starting.. [%s]" % gif_capture_label)
