extends Control


## The length and width of the grid
@export var grid_size: int = 8
## The amount of mines to put in
@export var mine_amount: int = 6:
	set(v):
		mine_amount = clampi(v, 0, roundi(pow(grid_size, 8)))
		if mine_amount != v:
			printerr("Invalid mine amount")

## Vector representing an invalid cell
const NULL_CELL = Vector2i(-1, -1)
## The amount of time to wait after winning/losing
const AFTER_WIN_TIME = 2.0

## List of all the mine positions
var mines: Array[Vector2i]

## The grid of cells
@onready var grid: GridContainer = $ScrollContainer/CenterContainer/GridContainer


func _ready() -> void:
	grid.columns = grid_size # set the ui to match the amount of columns
	
	reset() # setup the grid
	
	for y in range(grid_size): # for each y position
		for x in range(grid_size): # for each x position
			
			# A new Button!
			var cell := Button.new()
			
			# The button's size
			cell.custom_minimum_size = Vector2(35, 35)
			
			# Allow it to be 
			cell.button_mask = MOUSE_BUTTON_MASK_LEFT | MOUSE_BUTTON_MASK_RIGHT
			
			# When it's pressed, it'll call cell_clicked with its position value as a parameter
			cell.pressed.connect(cell_clicked.bind(Vector2i(x, y), true))
			
			# Add this button to the grid
			grid.add_child(cell)


## Clears the buttons, clears and re-adds the mines, hides the player state label
func reset() -> void:
	$PlayerStateLabel.hide() # same as .visible = false
	
	for i in range(mine_amount):
		var pos: Vector2i
		while pos in mines: # set pos to a random cell in the grid (that hasn't already been chosen)
			pos = Vector2i(randi_range(0, grid_size - 1), randi_range(0, grid_size - 1))
		mines.append(pos)
	
	for button: Button in get_all_buttons(): # resets all of the buttons
		button.text = ""
		button.disabled = false
		button.self_modulate = Color.WHITE


func cell_clicked(at_pos: Vector2i, try_flagging := false) -> void:
	var button := get_button(at_pos)
	
	if try_flagging and Input.is_action_just_released("right_mouse"): # flag the cell
		button.text = "F" if button.text.is_empty() else "" # if flagged, clear, else flag
	else: # reveal the cell
		if button.text == "F": # if flagged disallow clicking
			return
		# disable the button so it can't be pressed again
		button.disabled = true
		
		match get_cell_value(at_pos): # gets the value of the cell (-1 is mine, 0 empty, >0 normal)
			-1:
				reveal_all_mines(at_pos) # player loses if it's a mine
				return # don't need to run player_won
			0:
				reveal_surrounding(at_pos) # reveal all the cells around this one
			_:
				reveal_cell(at_pos) # shows the value of this cell
		
		if player_won():
			reveal_player_state_label(true) # show the you won text
			await get_tree().create_timer(AFTER_WIN_TIME).timeout # wait a bit
			reset() # setup for next round


## Runs cell_clicked for each cell around this one (including this one) if not already 'clicked'
func reveal_surrounding(cell_pos: Vector2i) -> void:
	for y in range(cell_pos.y - 1, cell_pos.y + 2):
		if y < 0 or y >= grid_size: # check for invalid y 
			continue
		for x in range(cell_pos.x - 1, cell_pos.x + 2):
			if x < 0 or x >= grid_size: # check for invalid x
				continue
			var current_pos := Vector2i(x, y)
			var button := get_button(current_pos)
			if not button.disabled and button.text.is_empty(): # if cell has not been revealed yet
				button.disabled = true
				cell_clicked(current_pos) # reveal it


## Sets the button text associated with [param cell_pos] to its value
func reveal_cell(cell_pos: Vector2i) -> void:
	var value := str(get_cell_value(cell_pos))
	assert(value != "-1") # The cell should never me a mine
	if value == "0": # if zero just show nothing
		value = ""
	get_button(cell_pos).text = value


## Gets the amount of mines around this cell (-1 if it's a mine)
func get_cell_value(cell_pos: Vector2i) -> int:
	if cell_pos in mines:
		return -1 # a mine
	
	var result: int = 0 # if still 0 after looping through neighbors, it's empty
	for y in range(cell_pos.y - 1, cell_pos.y + 2):
		for x in range(cell_pos.x - 1, cell_pos.x + 2):
			if Vector2i(x, y) in mines:
				result += 1 # add up all neighboring mines
	
	return result


## Returns the button at the [param cell_pos]
func get_button(cell_pos: Vector2i) -> Button:
	if cell_pos.clampi(0, grid_size - 1) != cell_pos:
		return null # return null if the position is outside the bounds
	return grid.get_child((cell_pos.y * grid_size) + cell_pos.x)


## Makes the button at [param pos] show being a mine
func reveal_mine(pos: Vector2i) -> void:
	var button := get_button(pos)
	button.self_modulate = Color.RED
	button.text = "X"
	button.disabled = true


## Reveals all the mines in the grid [br]
## Starts with, well, [param starting_with]
func reveal_all_mines(starting_with := NULL_CELL) -> void:
	reveal_player_state_label() # show the losing label
	while not mines.is_empty(): # repeat until mines is empty
		var current_mine: Vector2i
		if starting_with != NULL_CELL:
			current_mine = starting_with # start with starting_with
			starting_with = NULL_CELL
		else:
			current_mine = mines.pick_random() # gets a random one
		reveal_mine(current_mine)
		mines.erase(current_mine)
		await get_tree().create_timer(0.1).timeout # waits a bit
	
	await get_tree().create_timer(AFTER_WIN_TIME).timeout # waits a bit more
	reset()


## Reveals the you won/lost label (with the correct text and color depending on [param won])
func reveal_player_state_label(won := false) -> void:
	$PlayerStateLabel.show() # same as .visible = true
	$PlayerStateLabel.label_settings.font_color = Color.GREEN if won else Color.RED
	$PlayerStateLabel.text = "You %s!" % ("Won" if won else "Lost")


## Checks if the player has won
func player_won() -> bool:
	var unrevealed: int = 0
	for i in get_all_buttons():
		if not i.disabled:
			unrevealed += 1
	return unrevealed <= mines.size()


## Returns an array of all the buttons
func get_all_buttons() -> Array[Button]:
	return grid.get_children() as Array[Button]
