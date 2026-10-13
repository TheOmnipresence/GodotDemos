extends CheckButton

@export var row: int = 1 ## the row the button is in 1-8
@export var collum: int = 1 ## the collum the button is in 1-8
@export var blocks_in_row = {  ## the number of blocks currently in a row
	"1": 0,
	"2": 0,
	"3": 0,
	"4": 0,
	"5": 0,
	"6": 0,
	"7": 0,
	"8": 0} 
@export var blocks_in_collum = {  ## the current number of blocks in a collum
	"1": 0,
	"2": 0,
	"3": 0,
	"4": 0,
	"5": 0,
	"6": 0,
	"7": 0,
	"8": 0} 
var blocks_that_in_collum_1 =[$"../CheckButton64"]


func _on_toggled(_toggled_on: bool) -> void:
	match collum: ## determines the collum the block is in
		1:
			print("yay")
			blocks_in_collum["1"] += 1
		2:
			blocks_in_collum["2"] += 1
		3:
			blocks_in_collum["3"] += 1
		4:
			blocks_in_collum["4"] += 1
		5:
			blocks_in_collum["5"] += 1
		6:
			blocks_in_collum["6"] += 1
		7:
			blocks_in_collum["7"] += 1
		8:
			blocks_in_collum["8"] += 1
	if blocks_in_collum["1"] >= 9:
		blocks_in_collum["1"] = 0 
		blocks_that_in_collum_1.toggled_on = false
	print(blocks_in_collum)
	print(collum)

# boi read this before you continue programming yes im talking to you future Terry you don't understand it yet --> https://docs.godotengine.org/en/stable/classes/class_checkbutton.html
