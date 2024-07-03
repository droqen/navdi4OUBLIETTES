@tool
extends RichTextLabel
class_name ChatterLabel

signal charprinted(c)
signal doneprinting()

@export var zero_on_ready : bool = true
@export var zero_on_enter : bool = false
@export var unfinished_done_on_exit : bool = false
@export var printing : bool = true
enum NotPrintingBehaviour { INSTANT_ZERO, STAY, BACKSPACE }
@export var printing_pace : int = 3
@export_enum("Instant Zero", "Stay", "Backspace") var not_printing_behaviour : int = NotPrintingBehaviour.BACKSPACE :
	set(v):
		not_printing_behaviour = v
		notify_property_list_changed()
var chardelay : int = 0
@export var backspace_pace : int = 3
@export var backspace_ratio_pace : float = 0.0
@export_category("Custom char delays")
@export var no_delay_chars : String = ''
@export var midi_delay : int = 15
@export var midi_delay_chars : String = ':,-'
@export var long_delay : int = 30
@export var long_delay_chars : String = '!?.'
enum DelayLength { NONE, NORMAL, MIDI, LONG }
@export_enum("None", "Normal", "Midi", "Long") var space_delay : int = DelayLength.NORMAL
@export_enum("None", "Normal", "Midi", "Long") var linebreak_delay : int = DelayLength.NORMAL
@export_enum("None", "Normal", "Midi", "Long") var tab_delay : int = DelayLength.NORMAL

func _ready() -> void:
	if not Engine.is_editor_hint():
		if zero_on_ready: visible_characters = 0
func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		if zero_on_enter: visible_characters = 0
func _exit_tree() -> void:
	if not Engine.is_editor_hint() and unfinished_done_on_exit and printing:
		visible_characters = -1
		doneprinting.emit()

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		pass
	elif chardelay > 0:
		chardelay -= 1
	elif not printing:
		match not_printing_behaviour:
			NotPrintingBehaviour.INSTANT_ZERO:
				visible_characters = 0
			NotPrintingBehaviour.BACKSPACE:
				if visible_ratio > 0:
					if backspace_pace > 0:
						if visible_characters < 0:
							visible_characters = len(get_parsed_text())-1
						else:
							visible_characters -= 1
						chardelay = backspace_pace - 1
					if backspace_ratio_pace > 0:
						visible_ratio -= backspace_ratio_pace
			NotPrintingBehaviour.STAY:
				pass # do nothing
	elif visible_characters >= 0 and visible_characters < len(get_parsed_text()):
		if printing_pace > 0:
			var c = get_parsed_text()[visible_characters]
			visible_characters += 1
			chardelay = printing_pace - 1
			oncharprinted(c)
			charprinted.emit(c)
			match c:
				' ':chardelay=[0,printing_pace,midi_delay,long_delay][space_delay]
				'\n':chardelay=[0,printing_pace,midi_delay,long_delay][linebreak_delay]
				'\t':chardelay=[0,printing_pace,midi_delay,long_delay][tab_delay]
				_:
					if c in no_delay_chars:chardelay=0
					if c in midi_delay_chars:chardelay=midi_delay
					if c in long_delay_chars:chardelay=long_delay
	elif visible_characters >= 0:
		doneprinting.emit()
		visible_characters = -1

func _validate_property(property: Dictionary):
	if property.name in ["backspace_pace", "backspace_ratio_pace"] and not_printing_behaviour != NotPrintingBehaviour.BACKSPACE:
		property.usage = PROPERTY_USAGE_NO_EDITOR

func oncharprinted(_c):
	pass#prints('printed',c)
