extends Node2D

## Main - Main game scene controller

@onready var spawner = $Managers/Spawner
@onready var spawn_point = $GameplayArea/SpawnPoint
@onready var fruit_container = $GameplayArea/FruitContainer
@onready var game_over_detector = $GameplayArea/GameOverDetector

@onready var score_label = $UI/ScoreLabel
@onready var high_score_label = $UI/HighScoreLabel
@onready var next_fruit_label = $UI/NextFruitLabel
@onready var combo_label = $UI/ComboLabel

func _ready() -> void:
	# Setup spawner references
	spawner.spawn_point = spawn_point
	spawner.fruit_container = fruit_container

	# Connect signals
	ScoreManager.score_changed.connect(_on_score_changed)
	ScoreManager.high_score_changed.connect(_on_high_score_changed)
	ScoreManager.combo_changed.connect(_on_combo_changed)
	spawner.next_fruit_changed.connect(_on_next_fruit_changed)
	game_over_detector.game_over_triggered.connect(_on_game_over)
	GameManager.game_started.connect(_on_game_started)

	# Initialize UI
	update_score_ui()
	update_high_score_ui()
	update_combo_ui()
	update_next_fruit_ui()

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

func _on_game_started() -> void:
	print("Game started!")

func _on_game_over() -> void:
	print("Game Over! Final Score: ", ScoreManager.score)
	# TODO: Show game over screen
	# For now, just restart after delay
	await get_tree().create_timer(2.0).timeout
	GameManager.restart_game()
