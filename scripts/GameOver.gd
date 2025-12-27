extends CanvasLayer

## GameOver - Game over screen with final score and options

@onready var final_score_label = $Panel/VBoxContainer/FinalScoreLabel
@onready var high_score_label = $Panel/VBoxContainer/HighScoreLabel
@onready var restart_button = $Panel/VBoxContainer/RestartButton
@onready var menu_button = $Panel/VBoxContainer/MenuButton

func _ready() -> void:
	# Connect buttons
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

	# Display scores
	final_score_label.text = "Final Score: " + str(ScoreManager.score)
	high_score_label.text = "High Score: " + str(ScoreManager.high_score)

	# Check if new high score
	if ScoreManager.score == ScoreManager.high_score and ScoreManager.score > 0:
		high_score_label.text = "🎉 NEW HIGH SCORE! 🎉"
		high_score_label.add_theme_color_override("font_color", Color(1, 0.84, 0))  # Gold

	# Play menu music
	AudioManager.play_menu_music()

func _on_restart_pressed() -> void:
	AudioManager.play_click_sound()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_menu_pressed() -> void:
	AudioManager.play_click_sound()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
