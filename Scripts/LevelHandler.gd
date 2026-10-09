extends Node2D

var pigs = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for pig in get_tree().get_nodes_in_group("Pig"):
		pigs.append(pig)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for pig in pigs:
		if pig == null:
			pigs.remove_at(pigs.find(pig))
	if pigs.size() <= 0:
		get_tree().reload_current_scene()
