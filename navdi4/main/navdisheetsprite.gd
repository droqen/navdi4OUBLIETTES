@tool
extends Sprite2D
class_name SheetSprite

@export var sheet : Sheet = null
@export var playing : bool = false
@export var frames : PackedInt32Array = [0, 1]
@export var ani_period : int = 8
@export var ani_index : int = 0
var ani_subindex : int = 0

func setup(newframes : PackedInt32Array = [], newperiod : int = -1):
	if !newframes.is_empty() and newframes != frames:
		frames = newframes
		ani_index = 0
		ani_subindex = 0
	if newperiod >= 0 and newperiod != ani_period:
		ani_period = newperiod
		ani_subindex = 0
	playing = (ani_period > 0 and len(frames) > 1)
	return self

func _ready():
	playing = not Engine.is_editor_hint()

func _get_configuration_warnings() -> PackedStringArray:
	return ["Do not leave a sheetsprite playing in edit mode"] if playing else []

func _physics_process(_delta: float) -> void:
	if playing:
		ani_subindex += 1
	
	if sheet and frames:
		texture = sheet.texture
		hframes = sheet.hframes
		vframes = sheet.vframes
		if ani_subindex >= ani_period:
			ani_subindex -= ani_period
			ani_index += 1
		ani_index = posmod(ani_index, len(frames))
		frame = frames[ani_index]
