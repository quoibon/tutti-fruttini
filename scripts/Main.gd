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

func _ready() -> void:
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

	# Initialize UI
	update_score_ui()
	update_high_score_ui()
	update_combo_ui()
	update_next_fruit_ui()
	update_shake_counter_ui()

	# Start game
	GameManager.start_game()
	ScoreManager.reset_score()

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

	# Update visual preview
	var radius = fruit_info.get("radius", 16)
	var color = Color(fruit_info.get("color", "#FFFFFF"))
	var texture = Utils.generate_circle_texture(radius, color)
	next_fruit_preview.texture = texture

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
	shake_manager.perform_shake()

func _on_refill_button_pressed() -> void:
	# TODO: Show rewarded ad (Milestone 3)
	# For now, just refill for free
	shake_manager.refill_shakes()
	print("Shakes refilled! (Ad integration coming in Milestone 3)")

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
