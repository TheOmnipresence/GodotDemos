extends RigidBody2D

# Has the mouse been clicked and not released?
var is_drag = false
# Is the mouse over the bird
var is_hover = false
# Has the bird been shot
var fired = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	freeze = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
# Multiply things like acceleration by delta to make them not go too fast
func _physics_process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and is_hover:
		if event.pressed:
			is_drag = true
			drag()
		else:
			is_drag = false
func drag():
	while(is_drag):
		await get_tree().create_timer(0.01).timeout
	freeze = false
#	gets direction from bird position to mouse position, flips it, then multiplies to make the force non-negligable
	apply_impulse(-global_position.direction_to(get_global_mouse_position()) * 2000)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Ground"):
		queue_free()


func _on_mouse_entered() -> void:
	is_hover = true


func _on_mouse_exited() -> void:
	is_hover = false
