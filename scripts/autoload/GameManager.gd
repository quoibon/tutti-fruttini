extends Node

## GameManager - Global game state management
## Handles game flow, fruit data loading, and game state

signal game_started
signal game_over
signal game_paused
signal game_resumed

var is_game_over: bool = false
var is_paused: bool = false
var fruit_data: Dictionary = {}
var fruit_scene: PackedScene

# Container dimensions (from spec)
const CONTAINER_WIDTH: float = 540.0
const CONTAINER_HEIGHT: float = 960.0
const WALL_THICKNESS: float = 20.0
const SPAWN_HEIGHT: float = 100.0
const DANGER_ZONE_HEIGHT: float = 80.0

func _ready() -> void:
	load_fruit_data()
	fruit_scene = preload("res://scenes/Fruit.tscn")

func load_fruit_data() -> void:
	var file = FileAccess.open("res://data/fruit_data.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var json = JSON.new()
		var parse_result = json.parse(json_string)

		if parse_result == OK:
			fruit_data = json.data
			print("Fruit data loaded: ", fruit_data["fruits"].size(), " fruits")
		else:
			push_error("Error parsing fruit_data.json")

		file.close()
	else:
		push_error("Could not open fruit_data.json")

func get_fruit_info(level: int) -> Dictionary:
	if fruit_data.has("fruits") and level >= 0 and level < fruit_data["fruits"].size():
		return fruit_data["fruits"][level]
	return {}

func start_game() -> void:
	is_game_over = false
	is_paused = false
	emit_signal("game_started")

func end_game() -> void:
	is_game_over = true
	emit_signal("game_over")

func pause_game() -> void:
	is_paused = true
	get_tree().paused = true
	emit_signal("game_paused")

func resume_game() -> void:
	is_paused = false
	get_tree().paused = false
	emit_signal("game_resumed")

func restart_game() -> void:
	get_tree().reload_current_scene()
	start_game()
