extends Node

## ShakeManager - Handles shake mechanic with limited uses

signal shake_count_changed(count: int)
signal shake_performed
signal shake_refilled

var shake_count: int = 50
var is_on_cooldown: bool = false
var shake_cooldown_timer: Timer

const MAX_SHAKES: int = 50
const SHAKE_COOLDOWN_TIME: float = 0.1
const SHAKE_IMPULSE_STRENGTH: float = 450.0

@onready var camera: Camera2D

func _ready() -> void:
	# Setup cooldown timer
	shake_cooldown_timer = Timer.new()
	shake_cooldown_timer.one_shot = true
	shake_cooldown_timer.wait_time = SHAKE_COOLDOWN_TIME
	shake_cooldown_timer.timeout.connect(_on_cooldown_timeout)
	add_child(shake_cooldown_timer)

	# Load saved shake count
	load_shake_count()

func perform_shake() -> void:
	if shake_count <= 0:
		print("No shakes remaining! Need refill.")
		return

	if is_on_cooldown:
		print("Shake on cooldown...")
		return

	if GameManager.is_game_over:
		return

	# Apply impulse to all fruits
	var fruits = get_tree().get_nodes_in_group("fruits")
	for fruit in fruits:
		if fruit is Fruit:
			var random_impulse = Vector2(
				randf_range(-SHAKE_IMPULSE_STRENGTH, SHAKE_IMPULSE_STRENGTH),
				randf_range(-SHAKE_IMPULSE_STRENGTH * 1.0125, 0)  # 6.75x vertical component (0.675 * 1.5)
			)
			fruit.apply_central_impulse(random_impulse)

	# Trigger camera shake
	if camera:
		trigger_camera_shake()

	# Haptic feedback (only if enabled in settings)
	if SaveManager.get_vibration_enabled():
		Input.vibrate_handheld(100)  # 100ms vibration

	# Play shake sound
	AudioManager.play_shake_sound()

	# Update shake count
	shake_count -= 1
	emit_signal("shake_count_changed", shake_count)
	save_shake_count()

	# Emit signal
	emit_signal("shake_performed")

	print("Shake performed! Remaining: ", shake_count)

	# Start cooldown
	is_on_cooldown = true
	shake_cooldown_timer.start()

func trigger_camera_shake() -> void:
	if not camera:
		return

	# Simple camera shake effect
	var shake_amount = 30.0
	var shake_duration = 0.3

	var original_pos = camera.offset
	var shake_timer = 0.0

	# Create tween for shake
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	# Shake sequence
	for i in range(5):
		var random_offset = Vector2(
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount)
		)
		tween.tween_property(camera, "offset", random_offset, shake_duration / 10.0)

	# Return to original
	tween.tween_property(camera, "offset", original_pos, shake_duration / 5.0)

func _on_cooldown_timeout() -> void:
	is_on_cooldown = false

func refill_shakes() -> void:
	shake_count = MAX_SHAKES
	emit_signal("shake_count_changed", shake_count)
	emit_signal("shake_refilled")
	save_shake_count()
	AudioManager.play_refill_sound()
	print("Shakes refilled to ", MAX_SHAKES)

func get_shake_count() -> int:
	return shake_count

func can_shake() -> bool:
	return shake_count > 0 and not is_on_cooldown and not GameManager.is_game_over

func save_shake_count() -> void:
	SaveManager.save_shake_count(shake_count)

func load_shake_count() -> void:
	shake_count = SaveManager.get_shake_count()
	emit_signal("shake_count_changed", shake_count)
