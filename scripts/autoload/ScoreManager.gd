extends Node

## ScoreManager - Handles scoring, combos, and high score tracking

signal score_changed(new_score: int)
signal high_score_changed(new_high_score: int)
signal combo_changed(multiplier: float)

var score: int = 0
var high_score: int = 0
var combo_multiplier: float = 1.0
var combo_timer: Timer

const COMBO_TIMEOUT: float = 3.0
const COMBO_INCREMENT: float = 0.1
const MAX_COMBO: float = 3.0

func _ready() -> void:
	print("🟢 ScoreManager _ready() START")
	# Create combo timer
	combo_timer = Timer.new()
	combo_timer.one_shot = true
	combo_timer.wait_time = COMBO_TIMEOUT
	combo_timer.timeout.connect(_on_combo_timeout)
	add_child(combo_timer)
	print("🟢 ScoreManager - combo timer created")

	# Load high score
	load_high_score()
	print("🟢 ScoreManager _ready() COMPLETE. High score: ", high_score)

func _notification(what: int) -> void:
	# Save high score when app is paused or closed (critical for Android)
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if score > high_score:
			high_score = score
			save_high_score()
		print("App pausing/closing - high score saved: ", high_score)

func reset_score() -> void:
	score = 0
	combo_multiplier = 1.0
	emit_signal("score_changed", score)
	emit_signal("combo_changed", combo_multiplier)

func add_score(base_points: int) -> void:
	# Calculate final points with combo multiplier
	var final_points = int(base_points * combo_multiplier)
	score += final_points

	# Increase combo
	increase_combo()

	# Check for new high score - save immediately every time
	if score > high_score:
		high_score = score
		emit_signal("high_score_changed", high_score)
		save_high_score()

	emit_signal("score_changed", score)
	print("Score: +", final_points, " (", base_points, " x ", combo_multiplier, ") = ", score)

func increase_combo() -> void:
	combo_multiplier = min(combo_multiplier + COMBO_INCREMENT, MAX_COMBO)
	combo_timer.start(COMBO_TIMEOUT)
	emit_signal("combo_changed", combo_multiplier)

func _on_combo_timeout() -> void:
	combo_multiplier = 1.0
	emit_signal("combo_changed", combo_multiplier)

func save_high_score() -> void:
	SaveManager.save_high_score(high_score)
	print("High score saved: ", high_score)

func load_high_score() -> void:
	high_score = SaveManager.get_high_score()
	print("High score loaded: ", high_score)
	emit_signal("high_score_changed", high_score)

func get_current_score() -> int:
	return score

func get_high_score() -> int:
	return high_score
