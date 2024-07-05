extends Node

@onready var land : DreamLand = load(
	"res://dreamlands/reality/realityland.tscn").instantiate()
@onready var dream : LiveDream = get_parent()

func _ready() -> void:
	dream.goto_new_land(land, "rmA")
