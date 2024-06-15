extends Panel
class_name TapPanel

signal tapped(pos)
signal moved(pos,relative)
signal released(pos)

var held_start_pos : Vector2
var held : bool = false
var pos : Vector2
var _held_touch_identifier : int

func release():
	pass

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var buttonEvent : InputEventMouseButton = event
		if buttonEvent.button_mask & MOUSE_BUTTON_LEFT:
			pos = get_global_mouse_position()
			held = buttonEvent.pressed
			if held: held_start_pos = pos
			(tapped if held else released).emit(pos)
	if event is InputEventMouseMotion:
		var motionEvent : InputEventMouseMotion = event
		if motionEvent.button_mask & MOUSE_BUTTON_LEFT and held:
			pos = get_global_mouse_position()
			(moved).emit(pos, event.relative)
	if event is InputEventScreenTouch:
		var tapEvent : InputEventScreenTouch = event
		if tapEvent.pressed:
			pos = get_global_mouse_position()
			held = true
			_held_touch_identifier = tapEvent.index
			if held: held_start_pos = pos
			(tapped).emit(pos)
		elif tapEvent.index == _held_touch_identifier:
			pos = get_global_mouse_position()
			held = false
			_held_touch_identifier = -1
			(released).emit(pos)
	if event is InputEventScreenDrag:
		var dragEvent : InputEventScreenDrag
		if held and dragEvent.index == _held_touch_identifier:
			pos = get_global_mouse_position()
			(moved).emit(pos, event.relative)
