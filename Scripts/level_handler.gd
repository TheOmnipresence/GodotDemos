class_name LevelHandler extends Node2D
## Level Number
@export var levelNum = 0
## All alive [Pig]s
var pigs: Array[Pig] = []



func _ready() -> void:
	for pig: Pig in get_tree().get_nodes_in_group("Pig"):
		pigs.append(pig) # Add all pigs in the scene to the list


func _process(_delta: float) -> void:
	for pig: Pig in pigs:
#		Removes pig from list if null (ignore the errors it functions)
		if pig == null:
			pigs.remove_at(pigs.find(pig))
	if pigs.is_empty():
		# Player has won, reset
		_next_level()

# Gets the next level and changes the scene to it
# str converts this level's number + 1 to a string
# concats that to the file path
# change_scene_to_file sets the scene
# Just make sure there is a level after
func _next_level():
	get_tree().change_scene_to_file("res://Scenes/level" + str(levelNum + 1) +".tscn")
