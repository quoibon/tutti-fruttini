extends Node

## AudioManager - Handles all game audio (music and sound effects)

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
const SFX_POOL_SIZE = 15  # Increased to support multiple simultaneous merges

# Audio settings
var music_volume: float = 0.4
var sfx_volume: float = 1.0
var music_enabled: bool = true
var sfx_enabled: bool = true

# Available merge sounds (will cycle through)
var current_merge_sound: int = 1
const MAX_MERGE_SOUNDS = 5

func _ready() -> void:
	# Setup music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)

	# Setup SFX pool
	for i in SFX_POOL_SIZE:
		var player = AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		sfx_players.append(player)

	# Load settings
	load_settings()

	# Apply initial volumes
	set_music_volume(music_volume)
	set_sfx_volume(sfx_volume)

func play_music(track_name: String, loop: bool = true) -> void:
	if not music_enabled:
		return

	# Try .ogg first, then .wav (support both formats)
	var path_ogg = "res://assets/sounds/music/" + track_name + ".ogg"
	var path_wav = "res://assets/sounds/music/" + track_name + ".wav"
	var path = ""

	if FileAccess.file_exists(path_ogg):
		path = path_ogg
	elif FileAccess.file_exists(path_wav):
		path = path_wav
	else:
		print("Music file not found: ", track_name)
		return

	var stream = load(path)
	if stream:
		music_player.stream = stream
		# Set loop for both OggVorbis and WAV
		if stream is AudioStreamOggVorbis:
			stream.loop = loop
		elif stream is AudioStreamWAV:
			if loop:
				stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			else:
				stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
		music_player.play()

func stop_music() -> void:
	music_player.stop()

func pause_music() -> void:
	music_player.stream_paused = true

func resume_music() -> void:
	music_player.stream_paused = false

func play_sfx(sfx_name: String) -> void:
	if not sfx_enabled:
		return

	# Try .wav first, then .mp3 (support both formats)
	var path_wav = "res://assets/sounds/sfx/" + sfx_name + ".wav"
	var path_mp3 = "res://assets/sounds/sfx/" + sfx_name + ".mp3"
	var path = ""

	if FileAccess.file_exists(path_wav):
		path = path_wav
	elif FileAccess.file_exists(path_mp3):
		path = path_mp3
	else:
		# Silently fail for missing audio files
		return

	var stream = load(path)
	if not stream:
		return

	# Find available player
	for player in sfx_players:
		if not player.playing:
			player.stream = stream
			player.play()
			return

	# All players busy, use first one
	sfx_players[0].stream = stream
	sfx_players[0].play()

func play_merge_sound() -> void:
	# Cycle through merge sounds for variety
	play_sfx("merge_0" + str(current_merge_sound))
	current_merge_sound += 1
	if current_merge_sound > MAX_MERGE_SOUNDS:
		current_merge_sound = 1

func play_drop_sound() -> void:
	play_sfx("drop")

func play_shake_sound() -> void:
	play_sfx("shake")

func play_game_over_sound() -> void:
	play_sfx("game_over")

func play_click_sound() -> void:
	play_sfx("click")

func play_refill_sound() -> void:
	play_sfx("refill")

func play_max_merge_sound() -> void:
	# Special sound for when two fruit 11s merge
	play_sfx("67")

func play_fruit_sound(fruit_level: int) -> void:
	# Play fruit-specific sound based on level (0-10)
	# Files are named 01-11 with full fruit names
	var file_number = fruit_level + 1

	# Map fruit levels to full file names
	var fruit_sound_files = {
		1: "01.BlueberrinniOctopussini",
		2: "02.SlimoLiAppluni",
		3: "03.PerochelloLemonchello",
		4: "04.PenguinoCocosino",
		5: "05.ChimpanziniBananini",
		6: "06.TorrtuginniDragonfrutinni",
		7: "07.UdinDinDinDinDun",
		8: "08.Graipussi Medussi",
		9: "09.CrocodildoPen",
		10: "10.ZibraZubraZibralini",
		11: "11.StrawberryElephant"
	}

	if fruit_sound_files.has(file_number):
		play_sfx(fruit_sound_files[file_number])
	else:
		print("No sound file for fruit level: ", fruit_level)

func play_menu_music() -> void:
	play_music("Menu-FootprintsPianoOnlyLOOP", true)

func play_game_music() -> void:
	play_music("Game-CaseToCaseAltPianoOnly", true)

func set_music_volume(volume: float) -> void:
	music_volume = clamp(volume, 0.0, 1.0)
	var db = linear_to_db(music_volume) if music_volume > 0 else -80
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), db)
	save_settings()

func set_sfx_volume(volume: float) -> void:
	sfx_volume = clamp(volume, 0.0, 1.0)
	var db = linear_to_db(sfx_volume) if sfx_volume > 0 else -80
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), db)
	save_settings()

func toggle_music() -> void:
	music_enabled = not music_enabled
	if music_enabled:
		set_music_volume(music_volume)
	else:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), -80)
	save_settings()

func toggle_sfx() -> void:
	sfx_enabled = not sfx_enabled
	if sfx_enabled:
		set_sfx_volume(sfx_volume)
	else:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), -80)
	save_settings()

func save_settings() -> void:
	SaveManager.save_audio_settings(music_volume, sfx_volume, music_enabled, sfx_enabled)

func load_settings() -> void:
	var settings = SaveManager.get_audio_settings()
	music_volume = settings.get("music_volume", 0.4)
	sfx_volume = settings.get("sfx_volume", 1.0)
	music_enabled = settings.get("music_enabled", true)
	sfx_enabled = settings.get("sfx_enabled", true)
