extends Node2D
class_name NavdiSolePlayer

signal escaped(code)

const SOLE_PLAYER_GROUP_NAME = '__nsp'

@export var player_parent_group : String = "PlayerParent"
@export var replaces_player_if_different : bool = false

static func GetPlayer(node_in_tree : Node) -> NavdiSolePlayer:
	return node_in_tree.get_tree().get_first_node_in_group(SOLE_PLAYER_GROUP_NAME)

func _ready() -> void:
	var prev_player = GetPlayer(self)
	if prev_player == null:
		# i'm the new player, let's go
		add_to_group(SOLE_PLAYER_GROUP_NAME)
		for parent in get_tree().get_nodes_in_group(player_parent_group):
			reparent.call_deferred(parent);
			break; # only do this for the first parent.
	else:
		# a player pre-exists.
		if (replaces_player_if_different
		and prev_player.scene_file_path != self.scene_file_path):
			# i want to replace the player.
			on_replace_player(prev_player)
			prev_player.queue_free() # and goodbye to the old.
			add_to_group(SOLE_PLAYER_GROUP_NAME)
			for parent in get_tree().get_nodes_in_group(player_parent_group):
				reparent.call_deferred(parent);
				break; # only do this for the first parent.
		else:
			# if i want to be kept: hide and delete me
			hide(); queue_free(); return;
	
	var dream = LiveDream.GetDream(self)
	if dream: dream.sole_player_replaced.emit(prev_player, self)

func escape(code):
	if is_instance_valid(self):
		escaped.emit(code)
		queue_free() # always delete a player who escapes.

func deplayer():
	remove_from_group(SOLE_PLAYER_GROUP_NAME)
	hide(); queue_free();

func on_replace_player(prev_player):
	position = prev_player.position
