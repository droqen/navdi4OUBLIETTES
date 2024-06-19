@tool
extends Node2D
class_name DreamRoom

@export var room_size : Vector2i = Vector2i(100, 100)
@export var dbg_outline_col : Color = Color("#993399")
@export var room_links : Array[String] = ['','','','']
@export_enum("Sides Blocked", "Wrap", "Escape", "Void") var blank_link_behaviour : int = BlankLinkBehaviour.WRAP

enum BlankLinkBehaviour {
	SIDES_BLOCKED,
	WRAP,
	ESCAPE,
	VOID,
}

@export var edge_margin : int = 0

func _ready() -> void:
	if Engine.is_editor_hint():
		if self.scene_file_path:
			name = self.scene_file_path.rsplit('/',true,1)[1].split('.',true,1)[0]
		
func _draw() -> void:
	if Engine.is_editor_hint():
		texture_filter = TEXTURE_FILTER_NEAREST
		draw_rect(Rect2(Vector2i.ZERO, room_size), dbg_outline_col, false)

var maze : Maze :
	get() : return get_maze()

var _maze : Maze

func get_maze() -> Maze:
	if _maze: return _maze
	for child in get_children():
		if child is Maze:
			_maze = child as Maze
			return _maze
	return null # ???
