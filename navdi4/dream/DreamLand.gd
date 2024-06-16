@tool
extends Node2D
class_name DreamLand

@export var autolinking : bool = false
var autolinking_buf : int = 0
@export var autosnapping : bool = false
var autosnapping_buf : int = 0
@export var labelsettings : LabelSettings

var room_inst_dict : Dictionary

func _ready():
	if not Engine.is_editor_hint():
		autolinking = false
		autosnapping = false
		process_mode = PROCESS_MODE_DISABLED # i dont process

func _physics_process(_delta: float) -> void:
	queue_redraw()
	if autolinking_buf > 0: autolinking_buf -= 1
	if autosnapping_buf > 0: autosnapping_buf -= 1
	if autolinking and autolinking_buf == 0:
		var rooms = get_children()
		var roomct : int = get_child_count()
		for i in range(roomct-1):
			for j in range(i+1,roomct):
				try_autolink(rooms[i], rooms[j])
		autolinking_buf = 20;
	elif autosnapping and autosnapping_buf == 0:
		var rooms = get_children()
		var roomct : int = get_child_count()
		for i in range(roomct):
			for dirid in range(4):
				try_autosnap(rooms[i], dirid)
		autosnapping_buf = 17;
	if labelsettings:
		var rooms = get_children()
		var roomct : int = get_child_count()
		for i in range(roomct):
			var room : Node2D = rooms[i]
			var label : Label = room.get_node_or_null("-LandRoomRabel")
			if label == null:
				label = Label.new()
				label.name = "-LandRoomRabel"
				room.add_child(label, false, Node.INTERNAL_MODE_BACK)
			if room is DreamRoom:
				label.text = room.name
				label.modulate = Color.WHITE
			else:
				label.text = "/!\\ Not DreamRoom"
				label.modulate = Color.YELLOW
			label.label_settings = labelsettings
			#room.add_child()
		
	
	self_modulate = lerp(self_modulate, Color(
		1,
		1-0.1 * autosnapping_buf,
		1-0.1 * autolinking_buf,
		1.0 if (autosnapping or autolinking) else 0.5
	), 0.1)

func _draw():
	for child in get_children():
		var room = child as DreamRoom
		if room:
			for i in range(4):
				var room2 = get_node_or_null(room.room_links[i])
				if room2:
					var dir = dirid2dir(i)
					draw_connected_rooms(room, dir, room2)

func roomcenter(room:DreamRoom) -> Vector2:
	return room.position + (room.room_size/2 as Vector2)
func roomuvpos(room:DreamRoom, uv:Vector2) -> Vector2:
	return room.position + (room.room_size as Vector2) * uv
func dir2uv(dir:Vector2i) -> Vector2:
	return Vector2(.5+.5*dir.x,.5+.5*dir.y)
const DIRS = [Vector2i.RIGHT, Vector2i.UP, Vector2i.LEFT, Vector2i.DOWN]
static func dirid2dir(dirid:int) -> Vector2i:
	return DIRS[dirid]
	
func draw_arrow(a:Vector2, b:Vector2, c:Color, w:float, arrowhead_size:float) -> void:
	var arrowdir = (b - a).normalized()
	draw_line(a, b, c, w)
	if arrowdir:
		draw_line(b, b - arrowdir.rotated(PI*0.25) * arrowhead_size, c, w)
		draw_line(b, b - arrowdir.rotated(PI*-.25) * arrowhead_size, c, w)

func draw_connected_rooms(room1:DreamRoom, dir:Vector2i, room2:DreamRoom, _oneway:bool = false) -> void:
	for pt in [0.35]:
		if dir.x < 0: pt = 1 - pt;
		if dir.y < 0: pt = 1 - pt;
		var uv1 : Vector2 = Vector2(pt,pt)
		var uv2 : Vector2 = Vector2(pt,pt)
		if dir.x: uv1.x = 0.5 + 0.5 * dir.x; uv2.x = 1-uv1.x
		if dir.y: uv1.y = 0.5 + 0.5 * dir.y; uv2.y = 1-uv1.y
		draw_arrow(roomuvpos(room1, uv1), roomuvpos(room2, uv2), Color.WHITE, 2.0, 10.0)

func try_get_room_inst(roomname:String) -> DreamRoom:
	prints("try_get_room_inst", roomname)
	if room_inst_dict.has(roomname):
		prints("it's in the dict",room_inst_dict.keys())
		return room_inst_dict[roomname]
	else:
		prints("it's not in the dict...")
		var room = get_node_or_null(roomname) as DreamRoom
		if room == null:
			return null
		else:
			var newroom = room.duplicate()
			prints("ok, duplicated")
			
			# this doesn't copy right for some reason
			newroom.room_links = room.room_links
			
			room_inst_dict[roomname] = newroom
			prints("hopefully returning the duplicate:",newroom,"not",room)
			return newroom

func get_travel_dirid_room_inst(roomname:String, dirid:int) -> DreamRoom:
	var room = get_node_or_null(roomname) as DreamRoom
	if room == null:
		push_error("(get_travel_dirid_room) DreamLand %s does not contain room of name %s" % [name, roomname])
		return null
	else:
		var room2 = try_get_room_inst(room.room_links[dirid])
		return room2

func try_autosnap(room:DreamRoom, dirid:int) -> void:
	var room2 = get_node_or_null(room.room_links[dirid])
	if room2:
		var dir : Vector2i = dirid2dir(dirid)
		var distsq = (roomuvpos(room,  dir2uv(dir)).distance_squared_to(
			roomuvpos(room2, dir2uv(-dir))))
		if distsq > 5000:
			room.room_links[dirid] = ''
			if room2.room_links[(dirid+2)%4] == room.name:
				room2.room_links[(dirid+2)%4] = ''
func try_autolink(room1:DreamRoom, room2:DreamRoom) -> void:
	for dirid in range(4):
		var dir : Vector2i = dirid2dir(dirid)
		var distsq = (roomuvpos(room1,  dir2uv(dir)).distance_squared_to(
			roomuvpos(room2, dir2uv(-dir))))
		if distsq < 200:
			room1.room_links[dirid] = room2.name
			room2.room_links[(dirid+2)%4] = room1.name
