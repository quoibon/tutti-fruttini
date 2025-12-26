extends RigidBody2D
class_name Fruit

## Fruit - Individual fruit physics object with merge detection

signal merged(fruit_a: Fruit, fruit_b: Fruit)

@export var level: int = 0
@export var score_value: int = 1

var fruit_info: Dictionary = {}
var is_merging: bool = false
var can_merge: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var merge_area: Area2D = $MergeArea
@onready var merge_area_shape: CollisionShape2D = $MergeArea/CollisionShape2D
@onready var merge_cooldown: Timer = $MergeCooldownTimer

func _ready() -> void:
	add_to_group("fruits")

	# Connect signals
	merge_area.area_entered.connect(_on_merge_area_entered)
	merge_cooldown.timeout.connect(_on_merge_cooldown_timeout)

	# Start cooldown to prevent instant merging on spawn
	merge_cooldown.start()

func initialize(fruit_level: int) -> void:
	level = fruit_level
	fruit_info = GameManager.get_fruit_info(level)

	if fruit_info.is_empty():
		push_error("Invalid fruit level: ", level)
		return

	# Set visual properties
	setup_visuals()

	# Set physics properties
	setup_physics()

	# Set score value
	score_value = fruit_info.get("score_value", 1)

func setup_visuals() -> void:
	var radius = fruit_info.get("radius", 16)
	var color = Color(fruit_info.get("color", "#FFFFFF"))

	# Create a simple colored circle sprite (placeholder until we have actual sprites)
	if sprite:
		# Generate circle texture
		var texture = Utils.generate_circle_texture(radius, color)
		sprite.texture = texture
		sprite.centered = true

func setup_physics() -> void:
	var radius = fruit_info.get("radius", 16)

	# Setup main collision shape
	if collision_shape:
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = radius
		collision_shape.shape = circle_shape

	# Setup merge area collision shape (95% of main radius)
	if merge_area_shape:
		var merge_circle = CircleShape2D.new()
		merge_circle.radius = radius * 0.95
		merge_area_shape.shape = merge_circle

	# Set physics material
	var physics_mat = PhysicsMaterial.new()
	physics_mat.friction = 0.4
	physics_mat.bounce = 0.3
	physics_material_override = physics_mat

	# Set collision layers and masks
	collision_layer = 2  # Fruits layer
	collision_mask = 1 | 2  # Collide with Walls (1) and Fruits (2)

	# Configure RigidBody2D
	contact_monitor = true
	max_contacts_reported = 8
	can_sleep = true

func _on_merge_area_entered(area: Area2D) -> void:
	if not can_merge or is_merging:
		return

	# Check if the other area is another fruit's merge area
	var other_fruit = area.get_parent()
	if not other_fruit is Fruit:
		return

	# Only merge if same level
	if other_fruit.level != level:
		return

	# Prevent double merging
	if other_fruit.is_merging:
		return

	# Check velocity threshold (prevent mid-air merges)
	if linear_velocity.length() > 100 or other_fruit.linear_velocity.length() > 100:
		return

	# Only let one fruit trigger the merge (prevent duplicate merges)
	if get_instance_id() > other_fruit.get_instance_id():
		return

	# Trigger merge
	perform_merge(other_fruit)

func perform_merge(other_fruit: Fruit) -> void:
	# Set merging flags
	is_merging = true
	other_fruit.is_merging = true

	# Calculate spawn position (midpoint)
	var spawn_pos = (global_position + other_fruit.global_position) / 2.0

	# Calculate average velocity
	var avg_velocity = (linear_velocity + other_fruit.linear_velocity) / 2.0

	# Add score
	ScoreManager.add_score(score_value * 2)

	print("Merging: ", fruit_info.get("display_name", "Unknown"), " + ",
		  other_fruit.fruit_info.get("display_name", "Unknown"))

	# Spawn next level fruit (if not max level)
	if level < 10:
		spawn_next_fruit(spawn_pos, avg_velocity)
	else:
		print("MAX LEVEL REACHED: Watermelon!")
		# Still spawn a watermelon for now
		spawn_next_fruit(spawn_pos, avg_velocity)

	# Remove both fruits
	queue_free()
	other_fruit.queue_free()

func spawn_next_fruit(pos: Vector2, velocity: Vector2) -> void:
	var new_level = min(level + 1, 10)
	var new_fruit = GameManager.fruit_scene.instantiate()

	# Add to scene tree
	get_parent().add_child(new_fruit)

	# Initialize and position
	new_fruit.global_position = pos
	new_fruit.initialize(new_level)
	new_fruit.linear_velocity = velocity * 0.5  # Reduce velocity slightly

func _on_merge_cooldown_timeout() -> void:
	can_merge = true
