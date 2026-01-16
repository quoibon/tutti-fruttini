extends Control

## MainMenu - Main menu scene with play button and playful animations

@onready var play_button = $VBoxContainer/PlayButton/PlayLabel
@onready var play_button_container = $VBoxContainer/PlayButton
@onready var play_left_icon = $VBoxContainer/PlayButton/LeftIcon
@onready var play_right_icon = $VBoxContainer/PlayButton/RightIcon
@onready var settings_button = $VBoxContainer/SettingsButton
@onready var how_to_play_button = $VBoxContainer/HowToPlayButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var high_score_label = $VBoxContainer/HighScoreLabel

var settings_scene: PackedScene
var tutorial_scene: PackedScene

# Animation constants
const HOVER_SCALE := 1.1
const PRESS_SCALE := 0.95
const ANIMATION_DURATION := 0.15
const WOBBLE_ANGLE := 2.0  # degrees

# Button colors (Italian Brainrot theme - vibrant and playful)
const PLAY_COLOR := Color(0.2, 0.8, 0.4)  # Bright green
const PLAY_HOVER_COLOR := Color(0.3, 0.9, 0.5)
const SETTINGS_COLOR := Color(0.95, 0.6, 0.2)  # Orange
const SETTINGS_HOVER_COLOR := Color(1.0, 0.7, 0.3)
const HOW_TO_PLAY_COLOR := Color(0.4, 0.6, 0.95)  # Blue
const HOW_TO_PLAY_HOVER_COLOR := Color(0.5, 0.7, 1.0)
const QUIT_COLOR := Color(0.85, 0.3, 0.3)  # Red
const QUIT_HOVER_COLOR := Color(0.95, 0.4, 0.4)

func _ready() -> void:
	print("MainMenu _ready() START")

	# Load scenes
	settings_scene = preload("res://scenes/Settings.tscn")
	tutorial_scene = preload("res://scenes/Tutorial.tscn")

	# Set random fruit icons for play button
	randomize_play_button_icons()

	# Style all buttons with vibrant colors and shadows
	_setup_button_styles()

	# Connect buttons - pressed signals
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	how_to_play_button.pressed.connect(_on_how_to_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# Connect hover and press animations for all buttons
	_setup_button_animations(play_button, play_button_container, PLAY_COLOR, PLAY_HOVER_COLOR)
	_setup_button_animations(settings_button, settings_button, SETTINGS_COLOR, SETTINGS_HOVER_COLOR)
	_setup_button_animations(how_to_play_button, how_to_play_button, HOW_TO_PLAY_COLOR, HOW_TO_PLAY_HOVER_COLOR)
	_setup_button_animations(quit_button, quit_button, QUIT_COLOR, QUIT_HOVER_COLOR)

	# Load and display high score
	high_score_label.text = "High Score: " + str(SaveManager.get_high_score())

	# Play menu music
	AudioManager.play_menu_music()
	print("MainMenu _ready() COMPLETE")

func _setup_button_styles() -> void:
	# Apply custom StyleBoxFlat to each button for vibrant appearance
	_apply_button_style(play_button, PLAY_COLOR)
	_apply_button_style(settings_button, SETTINGS_COLOR)
	_apply_button_style(how_to_play_button, HOW_TO_PLAY_COLOR)
	_apply_button_style(quit_button, QUIT_COLOR)

func _apply_button_style(button: Button, base_color: Color) -> void:
	# Create normal style
	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = base_color
	normal_style.corner_radius_top_left = 12
	normal_style.corner_radius_top_right = 12
	normal_style.corner_radius_bottom_left = 12
	normal_style.corner_radius_bottom_right = 12
	normal_style.shadow_color = Color(0, 0, 0, 0.4)
	normal_style.shadow_size = 4
	normal_style.shadow_offset = Vector2(2, 3)
	normal_style.content_margin_left = 20
	normal_style.content_margin_right = 20
	normal_style.content_margin_top = 10
	normal_style.content_margin_bottom = 10

	# Create hover style (slightly brighter)
	var hover_style := StyleBoxFlat.new()
	hover_style.bg_color = base_color.lightened(0.15)
	hover_style.corner_radius_top_left = 12
	hover_style.corner_radius_top_right = 12
	hover_style.corner_radius_bottom_left = 12
	hover_style.corner_radius_bottom_right = 12
	hover_style.shadow_color = Color(0, 0, 0, 0.5)
	hover_style.shadow_size = 6
	hover_style.shadow_offset = Vector2(3, 4)
	hover_style.content_margin_left = 20
	hover_style.content_margin_right = 20
	hover_style.content_margin_top = 10
	hover_style.content_margin_bottom = 10

	# Create pressed style (darker)
	var pressed_style := StyleBoxFlat.new()
	pressed_style.bg_color = base_color.darkened(0.1)
	pressed_style.corner_radius_top_left = 12
	pressed_style.corner_radius_top_right = 12
	pressed_style.corner_radius_bottom_left = 12
	pressed_style.corner_radius_bottom_right = 12
	pressed_style.shadow_color = Color(0, 0, 0, 0.3)
	pressed_style.shadow_size = 2
	pressed_style.shadow_offset = Vector2(1, 1)
	pressed_style.content_margin_left = 20
	pressed_style.content_margin_right = 20
	pressed_style.content_margin_top = 10
	pressed_style.content_margin_bottom = 10

	# Apply styles
	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.add_theme_stylebox_override("focus", normal_style)

func _setup_button_animations(button: Button, scale_target: Control, _base_color: Color, _hover_color: Color) -> void:
	# Set pivot to center for proper scaling
	scale_target.pivot_offset = scale_target.size / 2.0

	# Connect hover signals for scale animation
	button.mouse_entered.connect(func(): _on_button_hover(scale_target, true))
	button.mouse_exited.connect(func(): _on_button_hover(scale_target, false))

	# Connect press signals for press animation
	button.button_down.connect(func(): _on_button_press(scale_target, true))
	button.button_up.connect(func(): _on_button_press(scale_target, false))

func _on_button_hover(target: Control, is_hovering: bool) -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)

	if is_hovering:
		# Scale up and add subtle wobble
		tween.tween_property(target, "scale", Vector2(HOVER_SCALE, HOVER_SCALE), ANIMATION_DURATION)
		# Start wobble animation
		_start_wobble(target)
	else:
		# Scale back to normal
		tween.tween_property(target, "scale", Vector2.ONE, ANIMATION_DURATION)
		tween.parallel().tween_property(target, "rotation_degrees", 0.0, ANIMATION_DURATION)

func _on_button_press(target: Control, is_pressed: bool) -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)

	if is_pressed:
		# Quick scale down
		tween.tween_property(target, "scale", Vector2(PRESS_SCALE, PRESS_SCALE), 0.05)
	else:
		# Bounce back up (to hover scale if still hovering, otherwise normal)
		tween.tween_property(target, "scale", Vector2(HOVER_SCALE, HOVER_SCALE), 0.1)

func _start_wobble(target: Control) -> void:
	var wobble_tween = create_tween()
	wobble_tween.set_loops(0)  # Infinite loops until stopped
	wobble_tween.set_ease(Tween.EASE_IN_OUT)
	wobble_tween.set_trans(Tween.TRANS_SINE)
	wobble_tween.tween_property(target, "rotation_degrees", WOBBLE_ANGLE, 0.15)
	wobble_tween.tween_property(target, "rotation_degrees", -WOBBLE_ANGLE, 0.3)
	wobble_tween.tween_property(target, "rotation_degrees", 0.0, 0.15)

func randomize_play_button_icons() -> void:
	# Pick two random fruit levels (0-10)
	var left_fruit = randi() % 11
	var right_fruit = randi() % 11

	# Load and set sprites
	load_fruit_icon(play_left_icon, left_fruit)
	load_fruit_icon(play_right_icon, right_fruit)

func load_fruit_icon(sprite: TextureRect, fruit_level: int) -> void:
	var sprite_files = {
		0: "1.BlueberrinniOctopussini",
		1: "2.SlimoLiAppluni",
		2: "3.PerochelloLemonchello",
		3: "4.PenguinoCocosino",
		4: "5.ChimpanziniBananini",
		5: "6.TorrtuginniDragonfrutinni",
		6: "7.UDinDinDinDinDun",
		7: "8.GraipussiMedussi",
		8: "9.CrocodildoPen",
		9: "10.ZibraZubraZibralini",
		10: "11.StrawberryElephant"
	}

	if not sprite_files.has(fruit_level):
		return

	var sprite_path = "res://assets/sprites/fruits/" + sprite_files[fruit_level] + ".png"
	var texture = ResourceLoader.load(sprite_path)
	if texture:
		sprite.texture = texture

func _on_play_pressed() -> void:
	AudioManager.play_click_sound()
	# Stop menu music before starting game
	AudioManager.stop_music()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_settings_pressed() -> void:
	AudioManager.play_click_sound()
	var settings = settings_scene.instantiate()
	add_child(settings)

func _on_how_to_play_pressed() -> void:
	AudioManager.play_click_sound()
	show_tutorial()

func show_tutorial() -> void:
	var tutorial = tutorial_scene.instantiate()
	add_child(tutorial)

func _on_quit_pressed() -> void:
	AudioManager.play_click_sound()
	get_tree().quit()
