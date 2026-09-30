extends Control


const DIRECTION_ATLAS: Dictionary[Vector2i, Vector2i] = {
	Vector2i.RIGHT: Vector2i(1, 0),
	Vector2i.LEFT: Vector2i(0, 1),
	Vector2i.DOWN: Vector2i(1, 1),
	Vector2i.UP: Vector2i(0, 0)
}
const INPUT_TO_DIRECTION: Dictionary[String, Vector2i] = {
	"up": Vector2i.UP,
	"down": Vector2i.DOWN,
	"left": Vector2i.LEFT,
	"right": Vector2i.RIGHT
}
const ORIGINAL_SNAKE: Array[Vector2i] = [Vector2i(4, 7), Vector2i(3, 7), Vector2i(2, 7)]

var snake: Array[Vector2i] = ORIGINAL_SNAKE.duplicate()
var last_dir := Vector2i.RIGHT
var last_pressed_dir_input: String
var ticking_paused: bool = false
var default_tiles: Dictionary[Vector2i, Vector2i]


@onready var tile_map_layer: TileMapLayer = $TileMapLayer


func _ready() -> void:
	for tile in tile_map_layer.get_used_cells():
		default_tiles[tile] = tile_map_layer.get_cell_atlas_coords(tile)


func _input(event: InputEvent) -> void:
	for type in ["up", "down", "left", "right"]:
		if event.is_action_pressed(type):
			if not event.is_echo():
				last_pressed_dir_input = type
				break


func tick() -> void:
	if ticking_paused:
		return
	advance_snake(tile_map_layer.get_cell_tile_data(snake[0] + get_dir()).get_custom_data("Type"))
	last_pressed_dir_input = ""


func get_dir() -> Vector2i:
	if not last_pressed_dir_input.is_empty():
		if INPUT_TO_DIRECTION[last_pressed_dir_input] == (snake[1] - snake[0]):
			return last_dir
		last_dir = INPUT_TO_DIRECTION[last_pressed_dir_input]
		return INPUT_TO_DIRECTION[last_pressed_dir_input]
	return last_dir


func advance_snake(type_ahead: String) -> void:
	if type_ahead.contains("Snake") or type_ahead == "Wall":
		update_win_lose_ui(false)
		$WinLosePanel.show() # same as .visible = true
		ticking_paused = true
		return
	var head: Vector2i = snake[0]
	var tail: Vector2i = snake[-1]
	snake.push_front(head + get_dir())
	tile_map_layer.set_cell(head, 0, get_snake_body(snake[2], snake[1], snake[0]))
	head = snake[0]
	tile_map_layer.set_cell(head, 0, get_snake_head())
	if type_ahead != "Apple":
		tile_map_layer.set_cell(tail, 0, Vector2i(8, 0))
		snake.remove_at(-1)
		tail = snake[-1]
		tile_map_layer.set_cell(tail, 0, get_snake_tail(tail - snake[-2]))
	else:
		spawn_new_apple()


func get_snake_body(body_before: Vector2i, body: Vector2i, body_after: Vector2i) -> Vector2i:
	if body_before.y == body_after.y:
		return Vector2i(1, 0)
	elif body_before.x == body_after.x:
		return Vector2i(1, 1)
	elif body_before.y != body.y:
		return Vector2i(2 if body.x > body_after.x else 0, 0 if body_before.y > body.y else 1)
	else:
		return Vector2i(0 if body_before.x > body.x else 2, 1 if body.y > body_after.y else 0)


func get_snake_head() -> Vector2i:
	return DIRECTION_ATLAS[get_dir()] + Vector2i(5, 0)


func get_snake_tail(diff: Vector2i):
	return DIRECTION_ATLAS[diff] + Vector2i(3, 0)


func spawn_new_apple() -> void:
	var list = tile_map_layer.get_used_cells().filter(
		func(e): return tile_map_layer.get_cell_tile_data(e).get_custom_data("Type") == "Ground")
	
	if list.is_empty(): # player has won
		update_win_lose_ui(true)
		$WinLosePanel.show() # same as .visible = true
	else:
		var cell: Vector2i = list.pick_random()
		tile_map_layer.set_cell(cell, 0, Vector2i(7, 0))


func update_win_lose_ui(won := false) -> void:
	$WinLosePanel/MarginContainer/VBoxContainer/Label.text = "You %s!" % ("Won" if won else "Lost")
	$WinLosePanel/MarginContainer/VBoxContainer/Button.text = "Play Again" if won else "Retry"


func reset_map() -> void:
	for tile: Vector2i in default_tiles:
		tile_map_layer.set_cell(tile, 0, default_tiles[tile])


func _on_button_pressed() -> void:
	$WinLosePanel.hide() # same as .visible = false
	reset_map()
	snake = ORIGINAL_SNAKE.duplicate()
	last_dir = Vector2i.RIGHT
	ticking_paused = false
