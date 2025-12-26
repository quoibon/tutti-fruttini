extends Node

## Spawner - Handles fruit spawning logic and input

signal fruit_spawned(fruit: Fruit)
signal next_fruit_changed(level: int)

@export var spawn_point: Marker2D
@export var fruit_container: Node2D

var can_spawn: bool = true
var next_fruit_level: int = 0
var spawn_cooldown: Timer

const SPAWN_COOLDOWN_TIME: float = 0.5
const SPAWN_POOL: Array[int] = [0, 1, 2, 3, 4]  # Only levels 0-4 can spawn
const SPAWN_WEIGHTS: Array[int] = [35, 30, 20, 10, 5]  # From fruit_data.json

func _ready() -> void:
	# Create spawn cooldown timer
	spawn_cooldown = Timer.new()
	spawn_cooldown.one_shot = true
	spawn_cooldown.wait_time = SPAWN_COOLDOWN_TIME
	spawn_cooldown.timeout.connect(_on_spawn_cooldown_timeout)
	add_child(spawn_cooldown)

	# Generate first next fruit
	generate_next_fruit()

func _input(event: InputEvent) -> void:
	# Handle touch/click input
	if event is InputEventScreenTouch and event.pressed:
		if can_spawn and not GameManager.is_game_over:
			var touch_pos = event.position
			drop_fruit_at_screen_pos(touch_pos)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if can_spawn and not GameManager.is_game_over:
			var mouse_pos = event.position
			drop_fruit_at_screen_pos(mouse_pos)

func drop_fruit_at_screen_pos(screen_pos: Vector2) -> void:
	# Convert screen position to world position
	var camera = get_viewport().get_camera_2d()
	var world_pos: Vector2

	if camera:
		world_pos = camera.get_global_mouse_position()
	else:
		# Fallback if no camera
		world_pos = get_viewport().get_canvas_transform().affine_inverse() * screen_pos

	drop_fruit(world_pos.x)

func drop_fruit(x_position: float) -> void:
	if not can_spawn or not spawn_point or not fruit_container:
		return

	# Clamp X position to container bounds
	var container_left = spawn_point.global_position.x - GameManager.CONTAINER_WIDTH / 2 + 30
	var container_right = spawn_point.global_position.x + GameManager.CONTAINER_WIDTH / 2 - 30
	var clamped_x = clamp(x_position, container_left, container_right)

	# Spawn fruit
	var fruit = GameManager.fruit_scene.instantiate()
	fruit_container.add_child(fruit)

	# Position at spawn point
	fruit.global_position = Vector2(clamped_x, spawn_point.global_position.y)

	# Initialize with next fruit level
	fruit.initialize(next_fruit_level)

	# Emit signal
	emit_signal("fruit_spawned", fruit)

	print("Spawned: ", GameManager.get_fruit_info(next_fruit_level).get("display_name", "Unknown"))

	# Start cooldown
	can_spawn = false
	spawn_cooldown.start()

	# Generate next fruit
	generate_next_fruit()

func generate_next_fruit() -> void:
	# Weighted random selection
	var total_weight = 0
	for weight in SPAWN_WEIGHTS:
		total_weight += weight

	var random_value = randi() % total_weight
	var cumulative_weight = 0

	for i in range(SPAWN_POOL.size()):
		cumulative_weight += SPAWN_WEIGHTS[i]
		if random_value < cumulative_weight:
			next_fruit_level = SPAWN_POOL[i]
			emit_signal("next_fruit_changed", next_fruit_level)
			return

	# Fallback
	next_fruit_level = 0
	emit_signal("next_fruit_changed", next_fruit_level)

func _on_spawn_cooldown_timeout() -> void:
	can_spawn = true

func get_next_fruit_level() -> int:
	return next_fruit_level
