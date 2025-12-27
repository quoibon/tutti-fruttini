extends Node2D

## Main - Main game scene controller

@onready var spawner = $Managers/Spawner
@onready var shake_manager = $Managers/ShakeManager
@onready var spawn_point = $GameplayArea/SpawnPoint
@onready var fruit_container = $GameplayArea/FruitContainer
@onready var game_over_detector = $GameplayArea/GameOverDetector
@onready var camera = $Camera2D

@onready var score_label = $UI/ScoreLabel
@onready var high_score_label = $UI/HighScoreLabel
@onready var next_fruit_label = $UI/NextFruitLabel
@onready var combo_label = $UI/ComboLabel
@onready var next_fruit_preview = $GameplayArea/NextFruitPreview
@onready var shake_button = $UI/ShakeButton
@onready var refill_button = $UI/RefillButton
@onready var pause_button = $UI/PauseButton  # Will be created in scene

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

	# Setup spawner references
	spawner.spawn_point = spawn_point
	spawner.fruit_container = fruit_container

	# Setup shake manager camera reference
	shake_manager.camera = camera

	# Connect signals
	ScoreManager.score_changed.connect(_on_score_changed)
	ScoreManager.high_score_changed.connect(_on_high_score_changed)
	ScoreManager.combo_changed.connect(_on_combo_changed)
	spawner.next_fruit_changed.connect(_on_next_fruit_changed)
	game_over_detector.game_over_triggered.connect(_on_game_over)
	GameManager.game_started.connect(_on_game_started)
	shake_manager.shake_count_changed.connect(_on_shake_count_changed)
	shake_button.pressed.connect(_on_shake_button_pressed)
	refill_button.pressed.connect(_on_refill_button_pressed)
	pause_button.pressed.connect(_on_pause_button_pressed)

	# Connect AdManager signals
	AdManager.reward_earned.connect(_on_ad_reward_earned)
	AdManager.free_refill_ready.connect(_on_free_refill_ready)
	AdManager.ad_failed_to_load.connect(_on_ad_failed)

	# Initialize UI
	update_score_ui()
	update_high_score_ui()
	update_combo_ui()
	update_next_fruit_ui()
	update_shake_counter_ui()

	# Start game
	GameManager.start_game()
	ScoreManager.reset_score()

	# Play game music
	AudioManager.play_game_music()

func _process(_delta: float) -> void:
	# Update preview position to follow mouse
	if not GameManager.is_game_over:
		update_preview_position()

func update_preview_position() -> void:
	var mouse_pos = get_global_mouse_position()

	# Clamp X position to container bounds
	var container_left = spawn_point.global_position.x - GameManager.CONTAINER_WIDTH / 2 + 30
	var container_right = spawn_point.global_position.x + GameManager.CONTAINER_WIDTH / 2 - 30
	var clamped_x = clamp(mouse_pos.x, container_left, container_right)

	# Update preview X position, keep Y fixed above spawn point
	next_fruit_preview.global_position.x = clamped_x

func _on_score_changed(new_score: int) -> void:
	update_score_ui()

func _on_high_score_changed(new_high_score: int) -> void:
	update_high_score_ui()

func _on_combo_changed(multiplier: float) -> void:
	update_combo_ui()

func _on_next_fruit_changed(level: int) -> void:
	update_next_fruit_ui()

func update_score_ui() -> void:
	score_label.text = "Score: " + str(ScoreManager.score)

func update_high_score_ui() -> void:
	high_score_label.text = "High Score: " + str(ScoreManager.high_score)

func update_combo_ui() -> void:
	var multiplier = ScoreManager.combo_multiplier
	combo_label.text = "Combo: x" + ("%.1f" % multiplier)

	# Change color based on combo
	if multiplier >= 2.0:
		combo_label.add_theme_color_override("font_color", Color(1, 0, 0))  # Red
	elif multiplier > 1.0:
		combo_label.add_theme_color_override("font_color", Color(1, 0.5, 0))  # Orange
	else:
		combo_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))  # Gray

func update_next_fruit_ui() -> void:
	var next_level = spawner.get_next_fruit_level()
	var fruit_info = GameManager.get_fruit_info(next_level)
	var display_name = fruit_info.get("display_name", "Unknown")
	next_fruit_label.text = "Next: " + display_name

	# Update visual preview with actual sprite
	var radius = fruit_info.get("radius", 16)

	# Apply size scale for specific fruit levels (fruits 7-11)
	var size_scale = get_preview_size_scale(next_level)
	radius = radius * size_scale

	var sprite_loaded = try_load_preview_sprite(next_level)

	if not sprite_loaded:
		# Fallback: colored circle
		var color = Color(fruit_info.get("color", "#FFFFFF"))
		var texture = Utils.generate_circle_texture(radius, color)
		next_fruit_preview.texture = texture

	# Scale preview to match target size (sprites are 1024x1024)
	var target_scale = (radius * 2.0) / 1024.0
	next_fruit_preview.scale = Vector2(target_scale, target_scale)

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

	if not FileAccess.file_exists(sprite_path):
		return false

	var texture = load(sprite_path)
	if texture:
		next_fruit_preview.texture = texture
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
	# Show refill button if no shakes left
	if count <= 0:
		refill_button.visible = true
		shake_button.disabled = true
	else:
		refill_button.visible = false
		shake_button.disabled = false

func _on_shake_button_pressed() -> void:
	AudioManager.play_click_sound()
	shake_manager.perform_shake()

func _on_refill_button_pressed() -> void:
	AudioManager.play_click_sound()

	# Check if free refill is ready
	if AdManager.is_free_refill_ready():
		shake_manager.refill_shakes()
		refill_button.visible = false
		print("Free refill granted!")
	else:
		# Show rewarded ad
		AdManager.show_rewarded_ad()
		print("Loading rewarded ad...")

func update_shake_counter_ui() -> void:
	var count = shake_manager.get_shake_count()
	shake_button.text = "🔔 " + str(count) + "\nSHAKE"

	# Change button color based on shake count
	if count <= 0:
		shake_button.modulate = Color(1, 0.5, 0.5)  # Light red tint
	elif count <= 10:
		shake_button.modulate = Color(1, 0.8, 0.5)  # Light orange tint
	else:
		shake_button.modulate = Color(1, 1, 1)  # Normal

	# Update refill button text
	if refill_button.visible:
		if AdManager.is_free_refill_ready():
			refill_button.text = "🎁 FREE REFILL"
		else:
			var time_left = int(AdManager.get_free_refill_time_remaining())
			if time_left > 0:
				refill_button.text = "📺 Watch Ad\n(Free in " + str(time_left) + "s)"
			else:
				refill_button.text = "📺 Watch Ad to Refill"

# AdManager Callbacks

func _on_ad_reward_earned() -> void:
	print("Ad reward earned - refilling shakes")
	shake_manager.refill_shakes()
	refill_button.visible = false

func _on_free_refill_ready() -> void:
	print("Free refill is now available")
	if refill_button.visible:
		refill_button.text = "🎁 FREE REFILL"

func _on_ad_failed() -> void:
	print("Ad failed to load - free refill option available in 30s")

# Pause Functionality

func _on_pause_button_pressed() -> void:
	AudioManager.play_click_sound()
	show_pause_menu()

func show_pause_menu() -> void:
	var pause_menu = pause_scene.instantiate()
	add_child(pause_menu)

func get_preview_size_scale(fruit_level: int) -> float:
	# Match the size scaling in Fruit.gd
	# Fruits 7-11 (levels 6-10) are made 1.4x larger
	match fruit_level:
		6, 7, 8, 9, 10: return 1.4
		_: return 1.0
