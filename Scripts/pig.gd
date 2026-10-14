class_name Pig extends RigidBody2D


## If this pig is falling
var falling = false



func _physics_process(_delta: float) -> void:
	if linear_velocity.x > 220 or linear_velocity.y > 220:
		falling = true # If moving down


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Bird") or body.is_in_group("Ground") or falling:
		queue_free() # Delete if hit by bird or fell on ground
