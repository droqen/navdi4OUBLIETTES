@tool
extends Node2D
class_name F2FlagCheckpoint

static var ActiveCheckName : String = ''

func _ready() -> void:
	if not Engine.is_editor_hint():
		show()
		$Area2D.area_entered.connect(func(plr_area):
			ActiveCheckName = name
		)
		$SheetSprite.setup([40])
func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		pass
	else:
		if name == ActiveCheckName:
			$SheetSprite.setup([41,42,43,44],17)
			if has_node("ChatterLabel"): $ChatterLabel.printing = true
		else:
			$SheetSprite.setup([40])
			if has_node("ChatterLabel"): $ChatterLabel.printing = false

func _draw() -> void:
	if Engine.is_editor_hint():
		#for px in [-1,1]: for py in [-1,1]:
			#draw_line(Vector2.ZERO, Vector2(150*px,-110*py), Color.WHITE)
		draw_rect(Rect2(-150, -110, 300, 220), Color(1,1,1,.1))
