extends Node2D

## Main - Main game scene controller

@onready var spawner = $Managers/Spawner
@onready var shake_manager = $Managers/ShakeManager
@onready var spawn_point = $GameplayArea/SpawnPoint
@onready var fruit_container = $GameplayArea/FruitContainer
@onready var game_over_detector = $GameplayArea/GameOverDetector
@onready var camera = $Camera2D
@onready var background_sprite = $BackgroundSprite

@onready var score_label = $UI/ScoreLabel
@onready var high_score_label = $UI/HighScoreLabel
@onready var next_fruit_label = $UI/NextFruitLabel
@onready var next_fruit_sprite = $UI/NextFruitSprite
@onready var next_fruit_preview = $GameplayArea/NextFruitPreview
@onready var shake_button = $UI/ShakeButton

# Object pools
var fruit_pool: FruitPool
var particle_pool: ParticlePool

# Pause menu
var pause_scene: PackedScene

func _ready() -> void:
	# Load pause scene
	pause_scene = preload("res://scenes/Pause.tscn")

	# Setup object pools
	fruit_pool = FruitPool.new()
	particle_pool = ParticlePool.new()
	add_child(fruit_pool)
	$GameplayArea.add_child(particle_pool)

	# Scale background to fill screen
	scale_background_to_screen()

	# Connect tree exiting to save data (failsafe)
	tree_exiting.connect(_on_tree_exiting)

	# Setup spawner references
	spawner.spawn_point = spawn_point
	spawner.fruit_container = fruit_container

	# Setup shake manager camera reference
	shake_manager.camera = camera

	# Connect signals
	ScoreManager.score_changed.connect(_on_score_changed)
	ScoreManager.high_score_changed.connect(_on_high_score_changed)
	spawner.next_fruit_changed.connect(_on_next_fruit_changed)
	game_over_detector.game_over_triggered.connect(_on_game_over)
	GameManager.game_started.connect(_on_game_started)
	shake_manager.shake_count_changed.connect(_on_shake_count_changed)
	shake_button.pressed.connect(_on_shake_button_pressed)

	# Connect pause button if it exists
	var pause_button = get_node_or_null("UI/PauseButton")
	if pause_button:
		pause_button.pressed.connect(_on_pause_button_pressed)

	# Connect AdManager signals
	AdManager.reward_earned.connect(_on_ad_reward_earned)
	AdManager.ad_failed_to_load.connect(_on_ad_failed)

	# Initialize UI
	update_score_ui()
	update_high_score_ui()
	update_next_fruit_ui()
	update_shake_counter_ui()

	# Start game
	GameManager.start_game()
	ScoreManager.reset_score()

	# Play game music
	AudioManager.play_game_music()

func _input(event: InputEvent) -> void:
	# Handle pause with ESC key
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			if not GameManager.is_game_over:
				show_pause_menu()
				get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	# Update preview position to follow mouse
	if not GameManager.is_game_over:
		update_preview_position()
		check_fruits_out_of_bounds()

func update_preview_position() -> void:
	var mouse_pos = get_global_mouse_position()

	# Clamp X position to container bounds
	var container_left = spawn_point.global_position.x - GameManager.CONTAINER_WIDTH / 2 + 30
	var container_right = spawn_point.global_position.x + GameManager.CONTAINER_WIDTH / 2 - 30
	var clamped_x = clamp(mouse_pos.x, container_left, container_right)

	# Update preview X position, keep Y fixed above spawn point
	next_fruit_preview.global_position.x = clamped_x

func check_fruits_out_of_bounds() -> void:
	# Check all fruits to see if any have landed outside the container
	var container_center_x = 540  # Center of screen
	var container_center_y = 960  # Center of screen
	var container_left = container_center_x - GameManager.CONTAINER_WIDTH / 2
	var container_right = container_center_x + GameManager.CONTAINER_WIDTH / 2
	var container_bottom = container_center_y + GameManager.CONTAINER_HEIGHT / 2
	var container_top = container_center_y - GameManager.CONTAINER_HEIGHT / 2

	# Very strict margins - minimal tolerance
	var side_margin = 30  # Reduced from 80 to 30 pixels
	var bottom_margin = 50  # Reduced from 100 to 50 pixels
	var top_margin = 200  # Allow some space above for dropping fruits

	for fruit_node in fruit_container.get_children():
		if fruit_node is Fruit:
			var pos = fruit_node.global_position
			var velocity = fruit_node.linear_velocity.length()

			# Get fruit radius - handle different shape types
			var fruit_radius = 50  # Default
			if fruit_node.collision_shape and fruit_node.collision_shape.shape:
				if fruit_node.collision_shape.shape is CircleShape2D:
					fruit_radius = fruit_node.collision_shape.shape.radius
				else:
					# For other shapes, use a reasonable estimate
					fruit_radius = 50

			# Check if fruit center is significantly outside bounds
			# Also check if fruit has completely left the screen
			var is_slow = velocity < 200  # Reduced from 300 to 200 px/s
			var completely_outside = pos.y > container_bottom + bottom_margin + fruit_radius or \
									 pos.x < container_left - side_margin - fruit_radius or \
									 pos.x > container_right + side_margin + fruit_radius or \
									 pos.y < container_top - top_margin - fruit_radius

			if completely_outside or (is_slow and (
			   pos.x < container_left - side_margin or \
			   pos.x > container_right + side_margin or \
			   pos.y > container_bottom + bottom_margin)):
				print("GAME OVER! Fruit out of bounds - Position: ", pos, " Velocity: ", velocity, " Radius: ", fruit_radius)
				game_over_detector.trigger_game_over()
				return

func _on_score_changed(new_score: int) -> void:
	update_score_ui()

func _on_high_score_changed(new_high_score: int) -> void:
	update_high_score_ui()

func _on_next_fruit_changed(level: int) -> void:
	update_next_fruit_ui()

func update_score_ui() -> void:
	score_label.text = "Score: " + str(ScoreManager.score)

func update_high_score_ui() -> void:
	high_score_label.text = "High Score: " + str(ScoreManager.high_score)

func update_next_fruit_ui() -> void:
	var next_level = spawner.get_next_fruit_level()
	var fruit_info = GameManager.get_fruit_info(next_level)

	# Update visual preview with actual sprite
	var radius = fruit_info.get("radius", 16)

	# Apply size scale for specific fruit levels
	var size_scale = get_preview_size_scale(next_level)
	radius = radius * size_scale

	var sprite_loaded = try_load_preview_sprite(next_level)

	if not sprite_loaded:
		# Fallback: colored circle
		var color = Color(fruit_info.get("color", "#FFFFFF"))
		var texture = Utils.generate_circle_texture(radius, color)
		next_fruit_preview.texture = texture
		next_fruit_sprite.texture = texture

	# Scale preview to match target size (sprites are 1024x1024)
	var target_scale = (radius * 2.0) / 1024.0
	next_fruit_preview.scale = Vector2(target_scale, target_scale)

	# Scale static UI sprite smaller (50% of cursor preview size)
	var ui_scale = target_scale * 0.5
	next_fruit_sprite.scale = Vector2(ui_scale, ui_scale)

func try_load_preview_sprite(level: int) -> bool:
	# Map same as Fruit.gd
	var sprite_number = level + 1
	var sprite_files = {
		1: "1.BlueberrinniOctopussini",
		2: "2.SlimoLiAppluni",
		3: "3.PerochelloLemonchello",
		4: "4.PenguinoCocosino",
		5: "5.ChimpanziniBananini",
		6: "6.TorrtuginniDragonfrutinni",
		7: "7.UDinDinDinDinDun",
		8: "8.GraipussiMedussi",
		9: "9.CrocodildoPen",
		10: "10.ZibraZubraZibralini",
		11: "11.StrawberryElephant"
	}

	if not sprite_files.has(sprite_number):
		return false

	var sprite_path = "res://assets/sprites/fruits/" + sprite_files[sprite_number] + ".png"

	# Use ResourceLoader for exported builds
	var texture = ResourceLoader.load(sprite_path)
	if texture:
		next_fruit_preview.texture = texture
		next_fruit_sprite.texture = texture
		return true

	return false

func _on_game_started() -> void:
	print("Game started!")

func _on_game_over() -> void:
	print("Game Over! Final Score: ", ScoreManager.score)
	# Show game over screen after brief delay
	await get_tree().create_timer(1.0).timeout
	var game_over_scene = preload("res://scenes/GameOver.tscn").instantiate()
	add_child(game_over_scene)

func _on_shake_count_changed(count: int) -> void:
	update_shake_counter_ui()

func _on_shake_button_pressed() -> void:
	AudioManager.play_click_sound()

	# Check shake count - if 0, show ad; otherwise shake
	if shake_manager.get_shake_count() <= 0:
		# Show rewarded ad (or grant free refill if no internet)
		AdManager.show_rewarded_ad()
		print("Requesting shake refill...")
	else:
		# Perform shake
		shake_manager.perform_shake()

func update_shake_counter_ui() -> void:
	var count = shake_manager.get_shake_count()

	# Change button text based on shake count
	if count <= 0:
		shake_button.text = "WATCH AD\nRefill Shakes"
		shake_button.modulate = Color(1, 0.8, 0.3)  # Gold/yellow tint for ad
	else:
		shake_button.text = "SHAKE\n" + str(count)
		# Change button color based on shake count
		if count <= 10:
			shake_button.modulate = Color(1, 0.8, 0.5)  # Light orange tint
		else:
			shake_button.modulate = Color(1, 1, 1)  # Normal

# AdManager Callbacks

func _on_ad_reward_earned() -> void:
	print("Ad reward earned - refilling shakes")
	shake_manager.refill_shakes()

func _on_ad_failed() -> void:
	print("Ad failed to load")

# Pause Functionality

func _on_pause_button_pressed() -> void:
	AudioManager.play_click_sound()
	show_pause_menu()

func show_pause_menu() -> void:
	GameManager.pause_game()  # This will save data
	var pause_menu = pause_scene.instantiate()
	add_child(pause_menu)

func get_preview_size_scale(fruit_level: int) -> float:
	# Match the size scaling in Fruit.gd
	match fruit_level:
		1: return 1.43  # Fruit 2 (Apple) - 1.3 * 1.1 = 10% larger
		2, 3: return 1.32  # Fruits 3-4 (Lemon, Coconut) - 1.2 * 1.1 = 10% larger
		4: return 1.247  # Fruit 5 (Banana) - 1.134 * 1.1 = 10% larger
		5: return 1.021  # Fruit 6 - 90% of 1.134
		6: return 1.078  # Fruit 7 - 110% of 0.98
		7: return 0.84  # Fruit 8 - 60% of 1.4
		8: return 0.857  # Fruit 9 - reduced by 20% from 1.071
		9: return 0.857  # Fruit 10 - reduced by 20% from 1.071
		10: return 0.911  # Fruit 11 - 90% of 1.012
		_: return 1.0

func _on_tree_exiting() -> void:
	# Failsafe: Save data when Main scene is exiting
	if ScoreManager.score > ScoreManager.high_score:
		ScoreManager.high_score = ScoreManager.score
		ScoreManager.save_high_score()
	SaveManager.save_data()
	print("Main scene exiting - Data saved as failsafe")

func scale_background_to_screen() -> void:
	if not background_sprite or not background_sprite.texture:
		return

	# Get screen size
	var screen_size = get_viewport_rect().size

	# Get background texture size
	var texture_size = background_sprite.texture.get_size()

	# Calculate scale needed to cover entire screen
	# Use max to ensure we cover both width and height
	var scale_x = screen_size.x / texture_size.x
	var scale_y = screen_size.y / texture_size.y
	var scale = max(scale_x, scale_y)

	# Apply scale (add 5% extra to ensure no gaps)
	background_sprite.scale = Vector2(scale * 1.05, scale * 1.05)

	print("Background scaled to: ", background_sprite.scale)
