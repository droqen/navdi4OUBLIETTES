@tool
extends Node2D
class_name DreamRoom

@export var room_size : Vector2i = Vector2i(100, 100)
@export var dbg_outline_col : Color = Color("#993399")
@export var room_links : Array[String] = ['','','','']
@export_enum("Blocked", "Wrap", "Escape") var blank_link_behaviour : int = BlankLinkBehaviour.WRAP

enum BlankLinkBehaviour {
	BLOCKED,
	WRAP,
	ESCAPE,
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
