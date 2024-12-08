extends Node2D

class_name LiveDream

const SOLE_LIVE_DREAM_NAME : String = "dreamN"
const SOLE_ROOM_GROUP_NAME : String = "-dCRGN"

signal sole_player_replaced(prevplayer, newplayer)
signal player_escaped(code)
signal windfish_awakened
signal windfish_lucidwake(memory)
signal songlink_signal(songlink)

@export var camera : Camera2D

var dreamland : DreamLand
var dreamroom : DreamRoom

func _ready():
	windfish_awakened.connect(func():prints(self,". . . WIND FISH AWAKENED . . ."))
	windfish_lucidwake.connect(func(memory):prints(self,". . . WIND FISH AWAKENED LUCIDLY RECALLING . . .", memory, ". . ."))
	songlink_signal.connect(func(songlink):prints(self,"songlink_signal - ",songlink.substr(0,30)," . . ."))
	add_to_group(SOLE_LIVE_DREAM_NAME)
	sole_player_replaced.connect(func(prevplayer, newplayer):
		if prevplayer: prevplayer.escaped.disconnect(self.player_escaped.emit)
		newplayer.escaped.connect(self.player_escaped.emit)
	)

func _physics_process(_delta: float) -> void:
	
	if not dreamroom or not dreamland: return
	
	var travel_dirid : int = -1
	var player = NavdiSolePlayer.GetPlayer(self)
	
	if player:
		if player.position.x < 0 + dreamroom.edge_margin:
			travel_dirid = 2
		elif player.position.x >= dreamroom.room_size.x - dreamroom.edge_margin:
			travel_dirid = 0
		elif player.position.y < 0 + dreamroom.edge_margin:
			travel_dirid = 1
		elif player.position.y >= dreamroom.room_size.y - dreamroom.edge_margin:
			travel_dirid = 3
	
	if travel_dirid >= 0:
		if dreamroom.room_links[travel_dirid] == '':
			match dreamroom.blank_link_behaviour:
				DreamRoom.BlankLinkBehaviour.WRAP:
					match travel_dirid:
						0: player.position.x = dreamroom.edge_margin;
						1: player.position.y = dreamroom.room_size.y - 1 - dreamroom.edge_margin;
						2: player.position.x = dreamroom.room_size.x - 1 - dreamroom.edge_margin;
						3: player.position.y = dreamroom.edge_margin;
				DreamRoom.BlankLinkBehaviour.VOID:
					pass # nothing happens
				DreamRoom.BlankLinkBehaviour.SIDES_BLOCKED:
					match travel_dirid:
						2: player.position.x = dreamroom.edge_margin;
						3: pass # player.position.y = dreamroom.room_size.y - 1 - dreamroom.edge_margin;
						0: player.position.x = dreamroom.room_size.x - 1 - dreamroom.edge_margin;
						1: pass # player.position.y = dreamroom.edge_margin;
				DreamRoom.BlankLinkBehaviour.ESCAPE:
					var escape_code : String = dreamroom.name
					set_dreamroom(null)
					if player: player.deplayer()
					dreamland = null
					player_escaped.emit(escape_code)
		else:
			var newroom = self.dreamland.get_travel_dirid_room_inst(dreamroom.name, travel_dirid)
			if newroom: set_dreamroom(newroom)
			prints("travel from room",dreamroom,"in dir",travel_dirid,"target room=",newroom)
			match travel_dirid:
				0: player.position.x = dreamroom.edge_margin;
				1: player.position.y = dreamroom.room_size.y - 1 - dreamroom.edge_margin;
				2: player.position.x = dreamroom.room_size.x - 1 - dreamroom.edge_margin;
				3: player.position.y = dreamroom.edge_margin;
			var travel_dir : Vector2i
			match travel_dirid:
				0: travel_dir = Vector2i( 1, 0)
				1: travel_dir = Vector2i( 0,-1)
				2: travel_dir = Vector2i(-1, 0)
				3: travel_dir = Vector2i( 0, 1)
			player.travelled_dir.emit(travel_dir)

func reload_dreamroom():
	var current_roomname : String = ''
	for child in get_children():
		if child is DreamRoom:
			current_roomname = child.name
	if current_roomname:
		dreamroom = null
		dreamland.forget_room_inst(current_roomname)
		set_dreamroom(
			dreamland.try_get_room_inst(current_roomname)
		)
	

func set_dreamroom(newroom : DreamRoom):
	if dreamroom == newroom:
		push_error("set_dreamroom to same room. dont do that")
		return
	
	for child in get_children():
		if child is DreamRoom:
			remove_child(child)
			#child.queue_free() # delete old dreamrooms
			#child.name = '(deleted)'
	for current_room in get_tree().get_nodes_in_group(SOLE_ROOM_GROUP_NAME):
		current_room.remove_from_group(SOLE_ROOM_GROUP_NAME)

	dreamroom = newroom#.duplicate()
	if dreamroom:
		dreamroom.add_to_group(SOLE_ROOM_GROUP_NAME)
		dreamroom.position = Vector2.ZERO
		add_child.call_deferred(dreamroom, true)
		update_camera_position()

func update_camera_position():
	prints("upcp",camera,dreamroom,dreamroom.position,dreamroom.room_size)
	if camera and dreamroom:
		camera.position = dreamroom.position + (dreamroom.room_size/2 as Vector2)

func goto_new_land(land: DreamLand, roomname: String, callback_mut_room: Callable = Callable()):
	var room : DreamRoom = land.try_get_room_inst(roomname)
	if room:
		var player = NavdiSolePlayer.GetPlayer(self)
		if player: player.queue_free()
		self.dreamland = land
		ProjectSettings.set_setting(
			"rendering/environment/defaults/default_clear_color",
			self.dreamland.background_colour
		)
		if not callback_mut_room.is_null(): callback_mut_room.call(room)
		self.set_dreamroom(room)
	else:
		push_error("goto_new_land failed; dreamland %s does not have room '%s'" % [land.name, roomname])

static func GetMaze(node_in_tree:Node) -> Maze:
	var room = GetRoom(node_in_tree)
	return room.maze if room else null
static func GetRoom(node_in_tree:Node) -> DreamRoom:
	return node_in_tree.get_tree().get_first_node_in_group(SOLE_ROOM_GROUP_NAME) as DreamRoom
static func GetDream(node_in_tree:Node) -> LiveDream:
	return node_in_tree.get_tree().get_first_node_in_group(SOLE_LIVE_DREAM_NAME) as LiveDream
