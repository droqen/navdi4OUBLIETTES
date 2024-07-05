extends Node

@onready var dream : LiveDream = get_parent()

const LAND_REALITY_PFB = preload("res://dreamlands/reality/realityland.tscn")
const LAND_O1_PFB = preload("res://dreamlands/oubliette-1/landO1.tscn")

#var landReal : DreamLand
#var landOub1 : DreamLand

enum { REALITY = 2341177, OUBLIETTE1 = 558137731, }
@onready var playst : TinyState = TinyState.new(REALITY, func(_then,now):
	pass
	#match REALITY:
		#dream.goto_new_land(land_Reality)
)

func _ready() -> void:
	dream.goto_new_land(LAND_REALITY_PFB.instantiate(), "rmA")
	dream.player_escaped.connect(func(code):
		await get_tree().create_timer(0.5).timeout
		prints("case:", playst.id, code)
		match [playst.id, code]:
			[REALITY, 8]:
				dream.goto_new_land(LAND_O1_PFB.instantiate(), "rmAB")
				playst.goto(OUBLIETTE1)
			[OUBLIETTE1, 8]:
				dream.goto_new_land(LAND_REALITY_PFB.instantiate(), "rmA", func(room):
					room.get_player().position = room.get_node("m_Win").position
				)
				playst.goto(REALITY)
			[OUBLIETTE1, 6]:
				dream.goto_new_land(LAND_REALITY_PFB.instantiate(), "rmA", func(room):
					room.get_player().position = room.get_node("m_Lose").position
					room.get_player().vel = Vector2(1.0,-1.8)
				)
				playst.goto(REALITY)
			_:
				prints("unknown case:", playst.id, code)
	)
