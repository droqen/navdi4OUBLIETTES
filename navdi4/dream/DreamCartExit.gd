@tool
extends Node2D
class_name DreamCartExit

const LBL_SETTINGS : LabelSettings = preload(
	"res://navdi4/dream/DreamCartExitLabelSettings.tres")

@export var cart : NavdiCart
@export var exitname : String
var _exit_valid : bool
var _not_engine : bool
@export var color : Color = Color.YELLOW;
@onready var colorrect = get_node_or_null("ColorRect")
@onready var label = get_node_or_null("Label")

func _ready() -> void:
	if Engine.is_editor_hint():
		if not has_node("ColorRect"):
			colorrect = ColorRect.new()
			colorrect.position = Vector2(-5,-5)
			colorrect.size = Vector2(10,10)
			colorrect.color = color
			add_child(colorrect)
			colorrect.owner = owner if owner else self
			
		if not has_node("Label"):
			label = Label.new()
			label.label_settings = LBL_SETTINGS
			label.size = Vector2(100,30)
			label.position = Vector2(-50,5)
			label.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			add_child(label)
			label.owner = owner if owner else self
			
	if not Engine.is_editor_hint():
		_not_engine = true
		if cart != null and exitname in cart.exits:
			_exit_valid = true
			label.hide()
		else:
			label.text = "invalid exit"

func _physics_process(_delta: float) -> void:
	if colorrect == null:
		colorrect = get_node_or_null("ColorRect")
	if colorrect != null:
		colorrect.color = color
	if _not_engine:
		var player = NavdiSolePlayer.GetPlayer(self)
		if (player != null
		and abs(player.position.x - position.x) < 5
		and abs(player.position.y - position.y) < 5):
			if _exit_valid:
				player.queue_free()
				LiveDream.GetDream(self).windfish_lucidwake.emit(exitname)
			else:
				queue_free() # invalid exit disappear
	else:
		if cart == null:
			change_label_text("( !!! )\nmissing cart")
		elif not cart.exits:
			change_label_text("( !!! )\ncart.exits empty")
		elif not exitname:
			change_label_text("( !!! )\nno exitname")
		elif not (exitname in cart.exits):
			change_label_text("( !!! )\nbad exit")
		else:
			if name != exitname: name = exitname
			change_label_text(exitname)

func change_label_text(new_text) -> void:
	if label.text != new_text: label.text = new_text
