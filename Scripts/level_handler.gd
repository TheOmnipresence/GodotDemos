class_name LevelHandler extends Node2D


var pigs = []



func _ready() -> void:
	for pig in get_tree().get_nodes_in_group("Pig"):
		pigs.append(pig)


func _process(_delta: float) -> void:
	for pig in pigs:
		if pig == null:
			pigs.remove_at(pigs.find(pig))
	if pigs.size() <= 0:
		get_tree().reload_current_scene()
