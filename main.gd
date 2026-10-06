extends Control


## The speed that the ground and cacti move (pixels per second) 
const SPEED = 600

## If the player has lost
var lost := false


func _ready() -> void:
	# Connect the reset button
	$GameOver/MarginContainer/VBoxContainer/Button.pressed.connect(reset)
	
	# Connect the cactus hit signal to the game over method
	$Dino/DamageArea.body_entered.connect(game_over.unbind(1))
	
	# Connect the cactus timer to tick
	$SpawnCactusTimer.timeout.connect(tick)
	# And start it
	$SpawnCactusTimer.start(5.0)


func _process(delta: float) -> void:
	# Check if the player has lost
	if not lost:
		# Move the ground to the left
		$Gound/TextureRect.position.x -= SPEED * delta
		
		# If it's further left from the origin than the size of the texture,
		# add the size of the texture to the position, effectively wrapping it around
		if $Gound/TextureRect.position.x < -$Gound/TextureRect.texture.get_size().x:
			$Gound/TextureRect.position.x += $Gound/TextureRect.texture.get_size().x
		
		# Iterate through the cacti, moving them to the left
		# if one is far enough off the screen, free it
		for i in $Cacti.get_children():
			i.position.x -= SPEED * delta
			if i.position.x < -100:
				i.queue_free()


func _physics_process(delta: float) -> void:
	# Check if the player has lost
	if not lost:
		
		# Add gravity to the dino's velocity
		if not $Dino.is_on_floor():
			$Dino.velocity += $Dino.get_gravity() * delta * 7
		
		# If ducking
		if Input.is_action_pressed("down"):
			$Dino/CollisionShape2D.shape.size.y = 50 # Decrease the height of the collision box
			$Dino/CollisionShape2D.position.y = 25 # Move the collision box down
			$Dino/Sprite2D.position.y = 25 # Move the sprite position down
			$Dino/Sprite2D.scale.y = 0.391 # Scale the sprite's height down
		else:
			$Dino/CollisionShape2D.shape.size.y = 100 # Reset the collision box's height
			$Dino/CollisionShape2D.position.y = 0 # and position
			$Dino/Sprite2D.scale.y = 0.781 # Reset the sprite's height
			$Dino/Sprite2D.position.y = 0 # and position
			
			if Input.is_action_just_pressed("jump"):
				if $Dino.is_on_floor():
					$Dino.velocity.y -= 1100 # jump
			elif Input.is_action_pressed("jump") and $Dino.velocity.y < 0:
				$Dino.velocity.y -= 60 # variable jump boost if you keep holding the button
		
		# Map velocity to position for the dino (when lost, not running this is how it stays in place)
		$Dino.move_and_slide()


## When the timer goes off
func tick() -> void:
	# Start the timer again
	$SpawnCactusTimer.start(randf_range(0.9,1.3))
	# Spawn a cactus
	spawn_cactus()


## Makes a new [Cactus] and adds it as a child of Cacti
func spawn_cactus() -> void:
	$Cacti.add_child(Cactus.new())


## Enter the "lost" state
func game_over() -> void:
	lost = true
	$GameOver.show() # Show the game over panel
	$SpawnCactusTimer.stop() # Stop the ticking


## Exit the "lost" state, deleting cacti and moving the dino back
func reset() -> void:
	lost = false
	$GameOver.hide() # Hide the game over panel
	for i in $Cacti.get_children(): # Delete all cacti
		i.queue_free()
	$Dino.position = Vector2(150, 381) # Reset the dino's position
	$SpawnCactusTimer.start(5) # Restart the ticking


class Cactus extends StaticBody2D:
	## A class for the cactus
	
	enum CactusType {
		ONE_SMALL, ## One small cactus
		ONE_LARGE, ## One large cactus
		TWO_SMALL, ## Two small cacti
		TWO_LARGE, ## Two large cacti
		THREE_SMALL, ## Three small cacti
		FOUR ## Four cacti
	}
	
	## The size of each [enum CactusType]
	const CACTUS_SIZES: Dictionary[CactusType, Vector2] = {
		CactusType.ONE_SMALL: Vector2(20, 40),
		CactusType.ONE_LARGE: Vector2(35, 60),
		CactusType.TWO_SMALL: Vector2(40, 40),
		CactusType.TWO_LARGE: Vector2(70, 60),
		CactusType.THREE_SMALL: Vector2(60, 40),
		CactusType.FOUR: Vector2(80, 60)
	}
	
	## The [enum CactusType] of this node
	var type: CactusType
	
	
	func _init() -> void:
		type = CactusType.values().pick_random() # Pick a random type
		
		var collision_box := CollisionShape2D.new() # Make a new collision box
		collision_box.shape = RectangleShape2D.new() # Make the shape a rectangle,
		collision_box.shape.size = get_size() # setting the size to the correct value
		add_child(collision_box) # Add it as a child
		
		var texture := TextureRect.new() # Make a new texture rect
		texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE # Make it not expand to fit the image
		texture.texture = preload("res://icon.svg") # Add the image
		texture.size = get_size() # Set it to the right size
		texture.position = -get_size() / 2 # Move it so that it centers
		add_child(texture) # Add it as a child
		
		# Set the position to the bottom right corner of the screen
		position = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"),
				ProjectSettings.get_setting("display/window/size/viewport_height"))
		position.y *= 2.0/3.0 # Move the y-position to 2/3rds of the way down the screen
		position.y += -get_size().y / 2 # Move it up so that the bottom is at the point instead of the center
		
		set_collision_layer_value(1, false) # Make it not solid to the player
		set_collision_layer_value(2, true) # Make the damage area recognise it
		set_collision_mask_value(1, false) # Turn off masking (not needed)
	
	
	## Gets the size of this cactus
	func get_size() -> Vector2:
		return CACTUS_SIZES[type]
