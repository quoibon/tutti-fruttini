extends Control

## MainMenu - Main menu scene with play button

@onready var play_button = $VBoxContainer/PlayButton/PlayLabel
@onready var play_left_icon = $VBoxContainer/PlayButton/LeftIcon
@onready var play_right_icon = $VBoxContainer/PlayButton/RightIcon
@onready var settings_button = $VBoxContainer/SettingsButton
@onready var how_to_play_button = $VBoxContainer/HowToPlayButton  # Will be created in scene
@onready var quit_button = $VBoxContainer/QuitButton
@onready var high_score_label = $VBoxContainer/HighScoreLabel

var settings_scene: PackedScene
var tutorial_scene: PackedScene

func _ready() -> void:
	print("🟡 MainMenu _ready() START")

	# Load scenes
	print("🟡 MainMenu - preloading Settings scene...")
	settings_scene = preload("res://scenes/Settings.tscn")
	print("🟡 MainMenu - Settings scene loaded")

	print("🟡 MainMenu - preloading Tutorial scene...")
	tutorial_scene = preload("res://scenes/Tutorial.tscn")
	print("🟡 MainMenu - Tutorial scene loaded")

	# Set random fruit icons for play button
	print("🟡 MainMenu - randomizing play button icons...")
	randomize_play_button_icons()
	print("🟡 MainMenu - play button icons set")

	# Connect buttons
	print("🟡 MainMenu - connecting button signals...")
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	how_to_play_button.pressed.connect(_on_how_to_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	print("🟡 MainMenu - buttons connected")

	# Load and display high score
	print("🟡 MainMenu - loading high score...")
	high_score_label.text = "High Score: " + str(SaveManager.get_high_score())
	print("🟡 MainMenu - high score displayed")

	# Play menu music
	print("🟡 MainMenu - starting menu music...")
	AudioManager.play_menu_music()
	print("🟡 MainMenu _ready() COMPLETE")

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

	var sprite_number = fruit_level + 1
	if not sprite_files.has(fruit_level):
		print("🟡 MainMenu - fruit level ", fruit_level, " not found in sprite_files")
		return

	var sprite_path = "res://assets/sprites/fruits/" + sprite_files[fruit_level] + ".png"
	print("🟡 MainMenu - loading fruit icon: ", sprite_path)

	# Use ResourceLoader for exported builds
	var texture = ResourceLoader.load(sprite_path)
	if texture:
		sprite.texture = texture
		print("🟡 MainMenu - fruit icon loaded successfully")
	else:
		print("🟡 MainMenu - FAILED to load fruit icon: ", sprite_path)

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
