extends Control


const SPEED = 600


var lost := false


func _ready() -> void:
	$GameOver/MarginContainer/VBoxContainer/Button.pressed.connect(reset)
	
	$Dino/DamageArea.body_entered.connect(game_over.unbind(1))
	
	$SpawnCactusTimer.timeout.connect(tick)
	$SpawnCactusTimer.start(5.0)


func _process(delta: float) -> void:
	if not lost:
		$Gound/TextureRect.position.x -= SPEED * delta
		if $Gound/TextureRect.position.x < -$Gound/TextureRect.texture.get_size().x:
			$Gound/TextureRect.position.x += $Gound/TextureRect.texture.get_size().x
		for i in $Cacti.get_children():
			i.position.x -= SPEED * delta
			if i.position.x < -100:
				i.queue_free()


func _physics_process(delta: float) -> void:
	if not lost:
		if not $Dino.is_on_floor():
			$Dino.velocity += $Dino.get_gravity() * delta * 7
		
		if Input.is_action_pressed("down"):
			$Dino/CollisionShape2D.shape.size.y = 50
			$Dino/CollisionShape2D.position.y = 25
			$Dino/Sprite2D.position.y = 25
			$Dino/Sprite2D.scale.y = 0.391
		else:
			$Dino/CollisionShape2D.shape.size.y = 100
			$Dino/CollisionShape2D.position.y = 0
			$Dino/Sprite2D.scale.y = 0.781
			$Dino/Sprite2D.position.y = 0
			
			if Input.is_action_just_pressed("jump"):
				if $Dino.is_on_floor():
					$Dino.velocity.y -= 1100
			elif Input.is_action_pressed("jump") and $Dino.velocity.y < 0:
				$Dino.velocity.y -= 60
		
		$Dino.move_and_slide()


func tick() -> void:
	$SpawnCactusTimer.start(randf_range(0.9,1.3))
	spawn_cactus()


func spawn_cactus() -> void:
	$Cacti.add_child(Cactus.new())


func game_over() -> void:
	lost = true
	$GameOver.show()
	$SpawnCactusTimer.stop()


func reset() -> void:
	lost = false
	$GameOver.hide()
	for i in $Cacti.get_children():
		i.queue_free()
	$Dino.position = Vector2(150, 381)
	$SpawnCactusTimer.start(5)


class Cactus extends StaticBody2D:
	
	enum CactusTypes {
		ONE_SMALL,
		ONE_LARGE,
		TWO_SMALL,
		TWO_LARGE,
		THREE_SMALL,
		FOUR
	}
	
	const CACTUS_SIZES: Dictionary[CactusTypes, Vector2] = {
		CactusTypes.ONE_SMALL: Vector2(20, 40),
		CactusTypes.ONE_LARGE: Vector2(35, 60),
		CactusTypes.TWO_SMALL: Vector2(40, 40),
		CactusTypes.TWO_LARGE: Vector2(70, 60),
		CactusTypes.THREE_SMALL: Vector2(60, 40),
		CactusTypes.FOUR: Vector2(80, 60)
	}
	
	var type: CactusTypes
	
	
	func _init() -> void:
		type = CactusTypes.values().pick_random()
		var collision_box := CollisionShape2D.new()
		collision_box.shape = RectangleShape2D.new()
		collision_box.shape.size = get_size()
		add_child(collision_box)
		var texture := TextureRect.new()
		texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture.texture = preload("res://icon.svg")
		texture.size = get_size()
		texture.position = -get_size() / 2
		add_child(texture)
		position = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height"))
		position.y *= 2.0/3.0
		position.y += -get_size().y / 2
		set_collision_layer_value(1, false)
		set_collision_layer_value(2, true)
		set_collision_mask_value(1, false)
	
	
	func get_size() -> Vector2:
		return CACTUS_SIZES[type]
