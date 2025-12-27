extends CanvasLayer

## Settings - Settings menu for audio and game options

@onready var music_volume_slider = $Panel/VBoxContainer/MusicVolumeContainer/MusicVolumeSlider
@onready var sfx_volume_slider = $Panel/VBoxContainer/SFXVolumeContainer/SFXVolumeSlider
@onready var music_toggle = $Panel/VBoxContainer/MusicToggleContainer/MusicToggle
@onready var sfx_toggle = $Panel/VBoxContainer/SFXToggleContainer/SFXToggle
@onready var vibration_toggle = $Panel/VBoxContainer/VibrationToggleContainer/VibrationToggle
@onready var back_button = $Panel/VBoxContainer/BackButton

func _ready() -> void:
	# Load current settings
	load_settings()

	# Connect signals
	music_volume_slider.value_changed.connect(_on_music_volume_changed)
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
	music_toggle.toggled.connect(_on_music_toggled)
	sfx_toggle.toggled.connect(_on_sfx_toggled)
	vibration_toggle.toggled.connect(_on_vibration_toggled)
	back_button.pressed.connect(_on_back_pressed)

func load_settings() -> void:
	var settings = SaveManager.get_audio_settings()

	# Set slider values (0.0-1.0 to 0-100)
	music_volume_slider.value = settings.get("music_volume", 0.6) * 100
	sfx_volume_slider.value = settings.get("sfx_volume", 1.0) * 100

	# Set toggle states
	music_toggle.button_pressed = settings.get("music_enabled", true)
	sfx_toggle.button_pressed = settings.get("sfx_enabled", true)
	vibration_toggle.button_pressed = SaveManager.get_vibration_enabled()

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
	AudioManager.play_click_sound()

func _on_sfx_toggled(enabled: bool) -> void:
	AudioManager.toggle_sfx()
	# Don't play click sound here as SFX might be disabled

func _on_vibration_toggled(enabled: bool) -> void:
	SaveManager.save_vibration_setting(enabled)
	AudioManager.play_click_sound()

	# Test vibration when enabled
	if enabled:
		Input.vibrate_handheld(100)

func _on_back_pressed() -> void:
	AudioManager.play_click_sound()
	queue_free()  # Close settings menu
