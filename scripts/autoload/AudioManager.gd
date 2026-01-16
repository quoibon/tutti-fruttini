extends Node

## AudioManager - Handles all game audio (music and sound effects)

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
const SFX_POOL_SIZE = 15  # Increased to support multiple simultaneous merges

# Audio settings
var music_volume: float = 0.4
var sfx_volume: float = 1.0

# Available merge sounds (will cycle through)
var current_merge_sound: int = 1
const MAX_MERGE_SOUNDS = 5

func _ready() -> void:
	print("🟢 AudioManager _ready() START")
	# Setup music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	print("🟢 AudioManager - music player created")

	# Setup SFX pool
	for i in SFX_POOL_SIZE:
		var player = AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		sfx_players.append(player)
	print("🟢 AudioManager - SFX pool created")

	# Load settings
	load_settings()
	print("🟢 AudioManager - settings loaded")

	# Apply initial volumes
	set_music_volume(music_volume)
	set_sfx_volume(sfx_volume)
	print("🟢 AudioManager _ready() COMPLETE")

func play_music(track_name: String, loop: bool = true) -> void:
	print("🎵 AudioManager.play_music() called: ", track_name)
	if music_volume <= 0:
		print("🎵 Music volume at 0, skipping")
		return

	# Try .ogg first, then .wav (support both formats)
	var path_ogg = "res://assets/sounds/music/" + track_name + ".ogg"
	var path_wav = "res://assets/sounds/music/" + track_name + ".wav"

	print("🎵 Attempting to load: ", path_ogg)
	# Use ResourceLoader for exported builds - try both formats
	var stream = ResourceLoader.load(path_ogg)
	if not stream:
		print("🎵 .ogg not found, trying .wav: ", path_wav)
		stream = ResourceLoader.load(path_wav)

	if not stream:
		print("🎵 Music file not found: ", track_name)
		return

	print("🎵 Music stream loaded successfully")
	music_player.stream = stream
	# Set loop for both OggVorbis and WAV
	if stream is AudioStreamOggVorbis:
		stream.loop = loop
	elif stream is AudioStreamWAV:
		if loop:
			stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		else:
			stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
	print("🎵 Starting music playback...")
	music_player.play()
	print("🎵 Music playback started")

func stop_music() -> void:
	music_player.stop()

func pause_music() -> void:
	music_player.stream_paused = true

func resume_music() -> void:
	music_player.stream_paused = false

func play_sfx(sfx_name: String) -> void:
	if sfx_volume <= 0:
		return

	# Try .wav first, then .mp3 (support both formats)
	var path_wav = "res://assets/sounds/sfx/" + sfx_name + ".wav"
	var path_mp3 = "res://assets/sounds/sfx/" + sfx_name + ".mp3"

	# Use ResourceLoader for exported builds - try both formats
	var stream = ResourceLoader.load(path_wav)
	if not stream:
		stream = ResourceLoader.load(path_mp3)

	if not stream:
		# Silently fail for missing audio files
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
	# No shake sound effect needed - silent
	pass

func play_game_over_sound() -> void:
	play_sfx("game_over")

func play_click_sound() -> void:
	# No click sound effect needed - silent
	pass

func play_refill_sound() -> void:
	play_sfx("refill")

func play_max_merge_sound() -> void:
	# Special sound for when two fruit 11s merge - plays 3 times for celebration
	_play_max_merge_sequence(3)

func _play_max_merge_sequence(times_remaining: int) -> void:
	if times_remaining <= 0:
		return

	# Find an available SFX player
	var player = _get_available_sfx_player()

	# Load the 67.mp3 sound file
	var stream = ResourceLoader.load("res://assets/sounds/sfx/67.mp3")
	if not stream:
		print("Max merge sound (67.mp3) not found")
		return

	# Play the sound
	player.stream = stream
	player.play()

	# If more plays remaining, connect to finished signal to play again
	if times_remaining > 1:
		# Disconnect any previous connections to avoid duplicates
		if player.finished.is_connected(_play_max_merge_sequence):
			player.finished.disconnect(_play_max_merge_sequence)

		# Connect for the next play
		player.finished.connect(_play_max_merge_sequence.bind(times_remaining - 1), CONNECT_ONE_SHOT)

func _get_available_sfx_player() -> AudioStreamPlayer:
	# Find an available SFX player (not currently playing)
	for player in sfx_players:
		if not player.playing:
			return player

	# All players busy, return the first one
	return sfx_players[0]

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

func save_settings() -> void:
	SaveManager.save_audio_settings(music_volume, sfx_volume)

func load_settings() -> void:
	var settings = SaveManager.get_audio_settings()
	music_volume = settings.get("music_volume", 0.4)
	sfx_volume = settings.get("sfx_volume", 1.0)
