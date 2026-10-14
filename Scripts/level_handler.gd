class_name LevelHandler extends Node2D


## All alive [Pig]s
var pigs: Array[Pig] = []



func _ready() -> void:
	for pig: Pig in get_tree().get_nodes_in_group("Pig"):
		pigs.append(pig) # Add all pigs in the scene to the list


func _process(_delta: float) -> void:
	for pig: Pig in pigs:
		if pig == null:
			pigs.erase(pig) # Remove pigs if they're null
	if pigs.is_empty():
		# Player has won, reset
		get_tree().reload_current_scene()
