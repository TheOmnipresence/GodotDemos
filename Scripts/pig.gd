extends RigidBody2D




func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Bird") or body.is_in_group("Ground"):
		queue_free()
	else:
		print(body)
