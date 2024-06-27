extends Node2D

class_name VictoryJewel

@export var purely_visual = false

const VICTORYBOLT_PFB = preload("res://dreamlands/ascend_demon/victorybolt.tscn")

const ROOTY = 45;

static var t : float = 0
static var spr_ani_index : int = 0
static var spr_ani_subindex : int = 0
static var AnyJewelCollected : bool = false
static var JewelCount : int = 0

func _ready():
	$pdet.connect("area_entered", func(area):
		var windiamond : Node2D = VICTORYBOLT_PFB.instantiate().setup(null, position as Vector2i)
		var player : Node2D = area.get_parent()
		get_parent().add_child(windiamond)
		windiamond.process_mode = Node.PROCESS_MODE_ALWAYS
		hide()
		queue_free()
		VictoryJewel.AnyJewelCollected = true
		VictoryJewel.JewelCount += 1
	)

func _enter_tree() -> void:
	print("jewel entered ",VictoryJewel.AnyJewelCollected)
	if AnyJewelCollected:
		modulate.a = 0.0
	position.y = ROOTY + sin(VictoryJewel.t)*1.0
	var spr = $SheetSprite
	spr.ani_index = spr_ani_index
	spr.ani_subindex = spr_ani_subindex
	spr.frame = spr.frames[spr.ani_index]


func _physics_process(delta: float) -> void:
	if AnyJewelCollected:
		var player = NavdiSolePlayer.GetPlayer(self)
		var dist_to_player = position.distance_to(player.position)
		if purely_visual: dist_to_player = 1000
		modulate.a = lerp(
			modulate.a,
			clampf(inverse_lerp(60,50,dist_to_player),0.0,1.0),
			0.05
		)
	VictoryJewel.t += delta * 2
	position.y = ROOTY + sin(VictoryJewel.t)*1.0
	VictoryJewel.spr_ani_index = $SheetSprite.ani_index
	VictoryJewel.spr_ani_subindex = $SheetSprite.ani_subindex
