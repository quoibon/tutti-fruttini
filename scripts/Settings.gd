extends CanvasLayer

## Settings - Settings menu for audio and game options

@onready var music_volume_slider = $Panel/ScrollContainer/VBoxContainer/MusicVolumeContainer/MusicVolumeSlider
@onready var sfx_volume_slider = $Panel/ScrollContainer/VBoxContainer/SFXVolumeContainer/SFXVolumeSlider
@onready var music_toggle = $Panel/ScrollContainer/VBoxContainer/MusicToggleContainer/MusicToggle
@onready var sfx_toggle = $Panel/ScrollContainer/VBoxContainer/SFXToggleContainer/SFXToggle
@onready var vibration_toggle = $Panel/ScrollContainer/VBoxContainer/VibrationToggleContainer/VibrationToggle
@onready var announce_drops_toggle = $Panel/ScrollContainer/VBoxContainer/AnnounceDropsContainer/AnnounceDropsToggle
@onready var developer_logo_button = $Panel/ScrollContainer/VBoxContainer/DeveloperContainer/DeveloperLogoButton
@onready var music_link_button = $Panel/ScrollContainer/VBoxContainer/MusicContainer/MusicLinkButton
@onready var back_button = $Panel/ScrollContainer/VBoxContainer/BackButton
@onready var top_back_button = $Panel/TopBackButton

func _ready() -> void:
	# Set process mode to ALWAYS so this works while paused
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Set layer to appear above pause menu and other UI
	layer = 10

	# Load current settings
	load_settings()

	# Load developer logo
	var logo_texture = ResourceLoader.load("res://assets/sprites/ui/bonsai_logo.png")
	if logo_texture:
		developer_logo_button.texture_normal = logo_texture
	else:
		print("Warning: Could not load developer logo")

	# Connect signals
	music_volume_slider.value_changed.connect(_on_music_volume_changed)
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
	music_toggle.toggled.connect(_on_music_toggled)
	sfx_toggle.toggled.connect(_on_sfx_toggled)
	vibration_toggle.toggled.connect(_on_vibration_toggled)
	announce_drops_toggle.toggled.connect(_on_announce_drops_toggled)
	back_button.pressed.connect(_on_back_pressed)
	top_back_button.pressed.connect(_on_back_pressed)

	# Connect credits buttons
	developer_logo_button.pressed.connect(_on_developer_logo_pressed)
	developer_logo_button.mouse_entered.connect(_on_logo_mouse_entered)
	developer_logo_button.mouse_exited.connect(_on_logo_mouse_exited)
	music_link_button.pressed.connect(_on_music_link_pressed)

func load_settings() -> void:
	var settings = SaveManager.get_audio_settings()

	# Set slider values (0.0-1.0 to 0-100)
	music_volume_slider.value = settings.get("music_volume", 0.4) * 100
	sfx_volume_slider.value = settings.get("sfx_volume", 1.0) * 100

	# Set toggle states and update text
	var music_enabled = settings.get("music_enabled", true)
	music_toggle.button_pressed = music_enabled
	music_toggle.text = "ON" if music_enabled else "OFF"

	var sfx_enabled = settings.get("sfx_enabled", true)
	sfx_toggle.button_pressed = sfx_enabled
	sfx_toggle.text = "ON" if sfx_enabled else "OFF"

	var vibration_enabled = SaveManager.get_vibration_enabled()
	vibration_toggle.button_pressed = vibration_enabled
	vibration_toggle.text = "ON" if vibration_enabled else "OFF"

	var announce_enabled = SaveManager.get_announce_all_drops()
	announce_drops_toggle.button_pressed = announce_enabled
	announce_drops_toggle.text = "ON" if announce_enabled else "OFF"

func _on_music_volume_changed(value: float) -> void:
	# Convert 0-100 to 0.0-1.0
	var volume = value / 100.0
	AudioManager.set_music_volume(volume)
	AudioManager.play_click_sound()

func _on_sfx_volume_changed(value: float) -> void:
	# Convert 0-100 to 0.0-1.0
	var volume = value / 100.0
	AudioManager.set_sfx_volume(volume)
	AudioManager.play_click_sound()

func _on_music_toggled(enabled: bool) -> void:
	AudioManager.toggle_music()
	music_toggle.text = "ON" if enabled else "OFF"
	AudioManager.play_click_sound()

func _on_sfx_toggled(enabled: bool) -> void:
	AudioManager.toggle_sfx()
	sfx_toggle.text = "ON" if enabled else "OFF"
	# Don't play click sound here as SFX might be disabled

func _on_vibration_toggled(enabled: bool) -> void:
	SaveManager.save_vibration_setting(enabled)
	vibration_toggle.text = "ON" if enabled else "OFF"
	AudioManager.play_click_sound()

	# Test vibration when enabled
	if enabled:
		Input.vibrate_handheld(100)

func _on_announce_drops_toggled(enabled: bool) -> void:
	SaveManager.save_announce_all_drops(enabled)
	announce_drops_toggle.text = "ON" if enabled else "OFF"
	AudioManager.play_click_sound()

func _on_back_pressed() -> void:
	AudioManager.play_click_sound()
	queue_free()  # Close settings menu

func _on_developer_logo_pressed() -> void:
	AudioManager.play_click_sound()
	OS.shell_open("https://bonsaidotdot.com")

func _on_logo_mouse_entered() -> void:
	# Hover effect: scale up and brighten
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(developer_logo_button, "scale", Vector2(1.1, 1.1), 0.2)
	tween.tween_property(developer_logo_button, "modulate", Color(1.2, 1.2, 1.2, 1.0), 0.2)

func _on_logo_mouse_exited() -> void:
	# Reset to normal
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(developer_logo_button, "scale", Vector2(1.0, 1.0), 0.2)
	tween.tween_property(developer_logo_button, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)

func _on_music_link_pressed() -> void:
	AudioManager.play_click_sound()
	OS.shell_open("https://www.jacoblivesmusic.com")
