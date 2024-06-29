@tool
extends Area2D
class_name ChatToggleArea

signal toggle_changed(area,toggle_value)

@export var label : ChatterLabel
@export var enable_on_overlap : bool = true
@export var disable_on_no_overlap : bool = true

func _ready() -> void:
	if not get_shape_owners():
		var colshape2d = CollisionShape2D.new()
		colshape2d.name = "CollisionShape2D"
		colshape2d.shape = RectangleShape2D.new()
		await get_tree().process_frame
		add_child(colshape2d, true, Node.INTERNAL_MODE_DISABLED)
		colshape2d.owner = owner if owner else self
	if collision_layer == 1 and collision_mask == 1:
		collision_layer = 0; collision_mask = 0;
		set_collision_mask_value(2, true)
		# set mask '2' true, which is the navdi4 de facto player mask.

func _physics_process(_delta: float) -> void:
	if label:
		if get_overlapping_areas() or get_overlapping_bodies():
			if enable_on_overlap:
				label.printing = true
				toggle_changed.emit(self, true)
		else:
			if disable_on_no_overlap:
				label.printing = false
				toggle_changed.emit(self, false)
