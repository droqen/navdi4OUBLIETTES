@tool
extends Node2D
class_name NavdiMain

const MONTHS = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

#@export var refresh_icon : bool = false :
	#set(v) : if v : _refresh_icon()

const ICON_LOADING : Texture2D = preload("res://navdi4/editortools/icon_loading.png")

@export var icon_preview : Texture2D

@export var apply_cart : bool = false :
	set(v) : if v : _apply_cart()

@export var cart : NavdiCart = null

func _apply_cart() -> void:
	if Engine.is_editor_hint():
		if cart:
			if cart.birth_year == 0: cart.autofill_birth_today()
			AutomakeSpritesheetStuff.Make(cart.sheet_src, cart.tile_size)
			_cart = cart
			_sheet = AutomakeSpritesheetStuff.LastMakeResult_Sheet
			_tiles = AutomakeSpritesheetStuff.LastMakeResult_Tiles
			cart.apply_changes(self)
			name = "[[ %s ]]" % cart.name
		else:
			_cart = cart # ideally, null?
			_sheet = null
			_tiles = null
			name = "-- no cart inserted --"
		notify_property_list_changed()
		_refresh_icon()

var _cart : NavdiCart
var _sheet : Sheet
var _tiles : TileSet

func _refresh_icon() -> void:
	if Engine.is_editor_hint() and _cart and _sheet:
		AutomakeIcon2.MakeSave(_sheet, _cart.icon_idx)
		for s in ["application/boot_splash/image", "application/config/icon"]:
			ProjectSettings.set_setting(s,"res://icon.png")
		ProjectSettings.notify_property_list_changed()
		
		#EditorInterface.get_resource_filesystem().scan()
		var editor_interface = Engine.get_singleton("EditorInterface")
		editor_interface.get_resource_filesystem().scan()
		
		icon_preview = ICON_LOADING
		notify_property_list_changed()
		await get_tree().create_timer(0.1).timeout
		icon_preview = ResourceLoader.load("res://icon.png")
		notify_property_list_changed()

var screenshotting_enabled = false

func _ready() -> void:
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
		
		if cart and cart.play_script:
			prints("play go")
			var play = cart.play_script.new()
			$LiveDream.add_child(play)
			play.owner = owner if owner else self
			if play.has_method('play'):
				play.play.call_deferred($LiveDream)

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
	if Engine.is_editor_hint():
		if _cart != cart:
			_apply_cart()
			_cart = cart
	
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
				gif_capture_label = "%04d%02d%02d-%02d-%02d-%02d-%s" % [
					now['year'],now['month'] ,now['day'],
					now['hour'],now['minute'],now['second'],
					cart.name if (cart and cart.name) else 'noname'
				]
				DirAccess.make_dir_recursive_absolute("captures/%s"%gif_capture_label)
				var _gdignore_file = FileAccess.open("captures/.gdignore", FileAccess.WRITE)
				print("starting.. [%s]" % gif_capture_label)
