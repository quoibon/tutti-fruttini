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

	# Apply size scale for specific fruit levels
	var size_scale = get_size_scale_for_level(level)
	radius = radius * size_scale

	if sprite:
		# Try to load actual sprite image first
		var sprite_loaded = try_load_sprite_image()

		if not sprite_loaded:
			# Fallback: Generate colored circle if sprite not found
			var texture = Utils.generate_circle_texture(radius, color)
			sprite.texture = texture

		sprite.centered = true

		# Scale sprite to match target radius (sprites are 1024x1024)
		# Target diameter = radius * 2
		# Sprite size = 1024
		# Scale = (radius * 2) / 1024
		var target_scale = (radius * 2.0) / 1024.0
		sprite.scale = Vector2(target_scale, target_scale)

func try_load_sprite_image() -> bool:
	# Sprite files are named: [level+1].[FruitName].png
	# Example: "1.BlueberrinniOctopussini.png" for level 0
	var sprite_number = level + 1

	# Map of sprite file names (just the prefix number)
	var sprite_files = {
		1: "1.BlueberrinniOctopussini",
		2: "2.SlimoLiAppluni",
		3: "3.PerochelloLemonchello",
		4: "4.PenguinoCocosino",
		5: "5.ChimpanziniBananini",
		6: "6.TorrtuginniDragonfrutinni",
		7: "7.UDinDinDinDinDun",
		8: "8.GraipussiMedussi",
		9: "9.CrocodildoPen",
		10: "10.ZibraZubraZibralini",
		11: "11.StrawberryElephant"
	}

	if not sprite_files.has(sprite_number):
		return false

	var sprite_path = "res://assets/sprites/fruits/" + sprite_files[sprite_number] + ".png"

	if not FileAccess.file_exists(sprite_path):
		return false

	var texture = load(sprite_path)
	if texture:
		sprite.texture = texture
		return true

	return false

func setup_physics() -> void:
	var radius = fruit_info.get("radius", 16)

	# Apply size scale for specific fruit levels
	var size_scale = get_size_scale_for_level(level)
	radius = radius * size_scale

	# Collision radius adjustments per fruit level to better match sprites
	# Some fruits have visual elements that extend beyond the solid body
	var collision_scale = get_collision_scale_for_level(level)
	var collision_radius = radius * collision_scale

	# Setup main collision shape
	if collision_shape:
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = collision_radius
		collision_shape.shape = circle_shape

	# Setup merge area collision shape (100% of main radius for better detection)
	if merge_area_shape:
		var merge_circle = CircleShape2D.new()
		merge_circle.radius = collision_radius
		merge_area_shape.shape = merge_circle

	# Set physics material (low bounce for soft fruit feel)
	var physics_mat = PhysicsMaterial.new()
	physics_mat.friction = 0.5
	physics_mat.bounce = 0.117  # 0.09 * 1.3 = 1.3x bouncier
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

	# Check velocity threshold (prevent fast mid-air merges)
	# Allow merging if fruits are moving slowly or have settled
	# Increased threshold to allow merging even when fruits are still settling
	var combined_velocity = (linear_velocity.length() + other_fruit.linear_velocity.length()) / 2.0
	if combined_velocity > 500:  # Increased from 300 to 500
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

	# Spawn merge particles
	spawn_merge_particles(spawn_pos)

	# Calculate new fruit level
	var new_level = min(level + 1, 10)

	# Play sound for the NEW fruit being created (not the old merging fruits)
	AudioManager.play_fruit_sound(new_level)

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

func spawn_merge_particles(pos: Vector2) -> void:
	# Get particle pool from Main scene
	var main = get_tree().root.get_node_or_null("Main")
	if not main or not main.has_node("particle_pool"):
		return

	var particle_pool = main.get_node("particle_pool") as ParticlePool
	if not particle_pool:
		return

	# Get merge particle color from fruit data
	var particle_color = Color(fruit_info.get("merge_particle_color", "#FFFFFF"))
	var radius = fruit_info.get("radius", 16)

	# Emit particle effect using pool
	particle_pool.emit_merge_effect(pos, particle_color, radius)

func spawn_next_fruit(pos: Vector2, velocity: Vector2) -> void:
	var new_level = min(level + 1, 10)
	var new_fruit = GameManager.fruit_scene.instantiate()

	# Add to scene tree
	get_parent().add_child(new_fruit)

	# Initialize and position
	new_fruit.global_position = pos
	new_fruit.initialize(new_level)
	new_fruit.linear_velocity = velocity * 0.9  # Maintain most of the velocity

	# Pop-in animation for merged fruit (fast and subtle)
	new_fruit.scale = Vector2(1.15, 1.15)
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(new_fruit, "scale", Vector2(1.0, 1.0), 0.15)

func _on_merge_cooldown_timeout() -> void:
	can_merge = true

func get_size_scale_for_level(fruit_level: int) -> float:
	# Returns a size multiplier for specific fruit levels
	# Fruits 7-11 (levels 6-10) are made 1.4x larger
	match fruit_level:
		6, 7, 8, 9, 10: return 1.4  # Fruits 7-11 are 1.4x larger
		_: return 1.0  # Default - normal size

func get_collision_scale_for_level(fruit_level: int) -> float:
	# Returns a scale factor for collision radius per fruit level
	# Adjust these values to better match sprite visuals
	# Values < 1.0 make collision smaller, > 1.0 make it larger
	match fruit_level:
		0: return 0.90  # Blueberry/Cherry - slightly tighter
		1: return 0.88  # Slime Apple - tighter
		2: return 0.90  # Lemon - slightly tighter
		3: return 0.88  # Penguin Coconut - tighter
		4: return 0.87  # Chimpanzee Banana - tighter
		5: return 0.86  # Turtle Dragonfruit - tighter
		6: return 0.85  # Dragonfruit - tighter
		7: return 0.60  # Level 7 (particularly bad) - very tight for left/right
		8: return 0.83  # Grape Medusa - tighter
		9: return 0.85  # Crocodile Pen - tighter
		10: return 0.87  # Zebra/Watermelon - tighter
		_: return 1.0  # Default - no change
