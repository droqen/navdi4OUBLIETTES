extends Node2D

func _ready() -> void:
	cycle()
func _physics_process(_delta: float) -> void:
	if randf() < 0.01: cycle()
func cycle() -> void:
	var ct = 0;
	for child in get_children(): child.hide(); ct += 1;
	if randf() < 0.99: get_child(randi()%ct).show()
	if randf() < 0.05: get_child(randi()%ct).show()
