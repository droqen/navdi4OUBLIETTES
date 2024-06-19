extends Node2D
class_name NavdiSolePlayer

const SOLE_PLAYER_GROUP_NAME = '__nsp'

@export var player_parent_group : String = "PlayerParent"

static func GetPlayer(node_in_tree : Node) -> NavdiSolePlayer:
	return node_in_tree.get_tree().get_first_node_in_group(SOLE_PLAYER_GROUP_NAME)

func _ready() -> void:
	if GetPlayer(self) == null:
		# i'm the new player, let's go
		add_to_group(SOLE_PLAYER_GROUP_NAME)
		for parent in get_tree().get_nodes_in_group(player_parent_group):
			reparent.call_deferred(parent);
			break; # only do this for the first parent.
	else:
		# a player pre-exists. hide, and delete me.
		hide(); queue_free();

func deplayer():
	remove_from_group(SOLE_PLAYER_GROUP_NAME)
	hide(); queue_free();
