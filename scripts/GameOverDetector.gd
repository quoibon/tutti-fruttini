extends Area2D

## GameOverDetector - Detects fruits in danger zone and triggers game over

signal danger_started
signal danger_ended
signal game_over_triggered

@export var grace_period: float = 2.0

var fruits_in_danger: Array[Fruit] = []
var grace_timer: Timer
var is_in_danger: bool = false

func _ready() -> void:
	# Setup grace timer
	grace_timer = Timer.new()
	grace_timer.one_shot = true
	grace_timer.wait_time = grace_period
	grace_timer.timeout.connect(_on_grace_period_timeout)
	add_child(grace_timer)

	# Connect area signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# Set collision detection
	collision_layer = 8  # GameOverZone layer
	collision_mask = 2   # Detect Fruits layer
	monitoring = true

func _on_body_entered(body: Node2D) -> void:
	if body is Fruit:
		var fruit = body as Fruit

		# Ignore if fruit is moving fast (bouncing through)
		if fruit.linear_velocity.length() > 200:
			return

		# Add to danger list
		if not fruits_in_danger.has(fruit):
			fruits_in_danger.append(fruit)
			print("Fruit entered danger zone: ", fruit.fruit_info.get("display_name", "Unknown"))

			# Start grace period if this is the first fruit
			if fruits_in_danger.size() == 1:
				start_danger_mode()

func _on_body_exited(body: Node2D) -> void:
	if body is Fruit:
		var fruit = body as Fruit

		# Remove from danger list
		if fruits_in_danger.has(fruit):
			fruits_in_danger.erase(fruit)
			print("Fruit left danger zone")

			# End danger mode if no more fruits in danger
			if fruits_in_danger.is_empty():
				end_danger_mode()

func start_danger_mode() -> void:
	if is_in_danger:
		return

	is_in_danger = true
	grace_timer.start(grace_period)
	emit_signal("danger_started")
	print("DANGER! Grace period started: ", grace_period, " seconds")

func end_danger_mode() -> void:
	if not is_in_danger:
		return

	is_in_danger = false
	grace_timer.stop()
	emit_signal("danger_ended")
	print("Danger ended - fruits cleared from top")

func _on_grace_period_timeout() -> void:
	if fruits_in_danger.size() > 0:
		trigger_game_over()

func trigger_game_over() -> void:
	print("GAME OVER! Fruits remained in danger zone too long")
	emit_signal("game_over_triggered")
	GameManager.end_game()

func _process(_delta: float) -> void:
	# Continuously check velocity of fruits in danger zone
	# Remove fruits that are moving fast (they're just passing through)
	for fruit in fruits_in_danger.duplicate():
		if fruit and is_instance_valid(fruit):
			if fruit.linear_velocity.length() > 200:
				fruits_in_danger.erase(fruit)

	# If all fruits were fast-moving, end danger
	if is_in_danger and fruits_in_danger.is_empty():
		end_danger_mode()
