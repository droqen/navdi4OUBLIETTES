extends Node2D
class_name Checkpoint

@export var hidden_when_inactive = false

enum { NOTACTIVE, ACTIVE, }

static var CheckRoomName : String = ''#'rmA'
static var CheckName : String = ''#'checkpoint'

var flagst : TinyState = TinyState.new(NOTACTIVE, func(_then,now):
	match now:
		NOTACTIVE:
			$flagspr.setup([4])
			$yay.one_shot = true
			$yay.emitting = false
			if hidden_when_inactive: hide()
		ACTIVE:
			$flagspr.setup([5,6,7,8],8)
			$yay.one_shot = true
			$yay.restart() # emitting = true?
			CheckRoomName = get_parent().name
			CheckName = name
			show()
)

func _ready() -> void:
	$flagspr.setup([4]); $flagspr.frame = 4
	$plrdet.area_entered.connect(func(_area):
		flagst.goto(ACTIVE)
	)

func _physics_process(_delta: float) -> void:
	if flagst.id == ACTIVE and name != CheckName: flagst.goto(NOTACTIVE)

func _enter_tree() -> void:
	if get_parent().name == CheckRoomName and name == CheckName:
		flagst.goto(ACTIVE); $yay.emitting = false
	else:
		flagst.goto(NOTACTIVE)
