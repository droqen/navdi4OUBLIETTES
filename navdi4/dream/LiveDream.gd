extends Node2D

class_name LiveDream

signal player_escaped

@export var camera : Camera2D

var dreamland : DreamLand
var dreamroom : DreamRoom

func _ready():
	pass
	
func _physics_process(_delta: float) -> void:
	if not dreamroom or not dreamland: return
	
	var travel_dirid : int = -1
	var player = NavdiSolePlayer.GetPlayer(self)
	
	if player:
		if player.position.x < 0 + dreamroom.edge_margin:
			travel_dirid = 2
		elif player.position.y < 0 + dreamroom.edge_margin:
			travel_dirid = 1
		elif player.position.x >= dreamroom.room_size.x - dreamroom.edge_margin:
			travel_dirid = 0
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
				DreamRoom.BlankLinkBehaviour.BLOCKED:
					match travel_dirid:
						2: player.position.x = dreamroom.edge_margin;
						3: player.position.y = dreamroom.room_size.y - 1 - dreamroom.edge_margin;
						0: player.position.x = dreamroom.room_size.x - 1 - dreamroom.edge_margin;
						1: player.position.y = dreamroom.edge_margin;
				DreamRoom.BlankLinkBehaviour.ESCAPE:
					for child in get_children(): child.queue_free()
					if player: player.deplayer()
					dreamland = null
					dreamroom = null
					player_escaped.emit()
		else:
			var newroom = self.dreamland.get_travel_dirid_room(dreamroom.name, travel_dirid)
			if newroom: set_dreamroom(newroom)
			match travel_dirid:
				0: player.position.x = dreamroom.edge_margin;
				1: player.position.y = dreamroom.room_size.y - 1 - dreamroom.edge_margin;
				2: player.position.x = dreamroom.room_size.x - 1 - dreamroom.edge_margin;
				3: player.position.y = dreamroom.edge_margin;

func set_dreamroom(newroom : DreamRoom):
	for child in get_children():
		if child is DreamRoom:
			child.queue_free() # delete old dreamrooms
			child.name = '(deleted)'
	dreamroom = newroom.duplicate()
	dreamroom.room_links = newroom.room_links
	dreamroom.position = Vector2.ZERO
	add_child.call_deferred(dreamroom, true)
	update_camera_position()

func update_camera_position():
	if camera and dreamroom:
		camera.position = dreamroom.position + (dreamroom.room_size/2 as Vector2)

func goto_new_land(land: DreamLand, roomname: String):
	var room : DreamRoom = land.try_get_room(roomname)
	if room:
		var player = NavdiSolePlayer.GetPlayer(self)
		if player: player.queue_free()
		self.dreamland = land
		self.set_dreamroom(room)
	else:
		push_error("goto_new_land failed; dreamland %s does not have room '%s'" % [land.name, roomname])
