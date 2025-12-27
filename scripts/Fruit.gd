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

	# Try to generate collision from sprite, fallback to simple circle
	var collision_generated = try_generate_collision_from_sprite(radius)

	if not collision_generated:
		# Fallback: Use simple circle collision matching sprite radius
		# Setup main collision shape
		if collision_shape:
			var circle_shape = CircleShape2D.new()
			circle_shape.radius = radius
			collision_shape.shape = circle_shape

		# Setup merge area collision shape (same as main radius)
		if merge_area_shape:
			var merge_circle = CircleShape2D.new()
			merge_circle.radius = radius
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

func try_generate_collision_from_sprite(target_radius: float) -> bool:
	# Generate actual polygon collision shape from sprite alpha channel
	# Returns true if successful, false to fallback to circle

	var sprite_number = level + 1
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

	# Load the texture
	var texture = load(sprite_path) as Texture2D
	if not texture:
		return false

	# Get the image from texture
	var image = texture.get_image()
	if not image:
		return false

	# Generate polygon points from sprite outline
	var polygon_points = generate_polygon_from_image(image, target_radius)

	if polygon_points.size() < 3:
		return false  # Need at least 3 points for a polygon

	# Create convex polygon collision shape
	if collision_shape:
		var poly_shape = ConvexPolygonShape2D.new()
		poly_shape.points = polygon_points
		collision_shape.shape = poly_shape

	# Use same polygon for merge area
	if merge_area_shape:
		var merge_poly = ConvexPolygonShape2D.new()
		merge_poly.points = polygon_points
		merge_area_shape.shape = merge_poly

	return true

func generate_polygon_from_image(image: Image, target_radius: float) -> PackedVector2Array:
	# Generate a convex polygon outline from the sprite's alpha channel
	var img_width = image.get_width()
	var img_height = image.get_height()
	var center = Vector2(img_width / 2.0, img_height / 2.0)

	# Sample points around the perimeter at different angles
	var num_samples = 32  # Number of ray samples
	var points = PackedVector2Array()

	for i in range(num_samples):
		var angle = (float(i) / num_samples) * TAU
		var direction = Vector2(cos(angle), sin(angle))

		# Cast ray from center outward to find edge
		var max_distance = max(img_width, img_height)
		var edge_point = center

		for dist in range(1, int(max_distance / 2)):
			var sample_pos = center + direction * dist
			var x = int(sample_pos.x)
			var y = int(sample_pos.y)

			# Check if we're outside bounds or hit transparent pixel
			if x < 0 or x >= img_width or y < 0 or y >= img_height:
				break

			var pixel = image.get_pixel(x, y)
			if pixel.a > 0.1:  # Solid pixel (lower threshold to catch more pixels)
				edge_point = sample_pos
			elif edge_point != center:
				# We found the edge
				break

		# Convert from image space to world space
		# Center the polygon and scale to target radius
		var world_point = (edge_point - center) * (target_radius * 2.0 / img_width)

		points.append(world_point)

	# Ensure we have a valid convex hull
	if points.size() >= 3:
		return get_convex_hull(points)

	return PackedVector2Array()

func get_convex_hull(points: PackedVector2Array) -> PackedVector2Array:
	# Simple convex hull using gift wrapping algorithm
	if points.size() < 3:
		return points

	# Find the leftmost point
	var leftmost_idx = 0
	for i in range(points.size()):
		if points[i].x < points[leftmost_idx].x:
			leftmost_idx = i

	var hull = PackedVector2Array()
	var current = leftmost_idx

	while true:
		hull.append(points[current])
		var next = (current + 1) % points.size()

		for i in range(points.size()):
			if i == current:
				continue
			var cross = (points[next] - points[current]).cross(points[i] - points[current])
			if cross < 0:
				next = i

		current = next
		if current == leftmost_idx or hull.size() > points.size():
			break

	return hull

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

	print("Merging: ", fruit_info.get("display_name", "Unknown"), " + ",
		  other_fruit.fruit_info.get("display_name", "Unknown"))

	# Special case: Two fruit 11s (level 10) merging
	if level == 10:
		print("MAX LEVEL MERGE! Two Watermelons combined - BONUS POINTS!")
		# Give bonus points (5x the normal score value)
		ScoreManager.add_score(score_value * 5)
		# Play special max merge sound (67.mp3)
		AudioManager.play_max_merge_sound()
		# Don't spawn new fruit - just remove both
		queue_free()
		other_fruit.queue_free()
		return

	# Calculate new fruit level
	var new_level = min(level + 1, 10)

	# Play sound for the NEW fruit being created (not the old merging fruits)
	AudioManager.play_fruit_sound(new_level)

	# Add score
	ScoreManager.add_score(score_value * 2)

	# Spawn next level fruit
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
	match fruit_level:
		2, 3: return 1.2  # Fruits 3-4 are 1.2x larger
		4, 5: return 1.26  # Fruits 5-6 are 1.26x (1.4 * 0.9)
		6, 7: return 1.4  # Fruits 7-8 are 1.4x larger
		8: return 0.857  # Fruit 9 - reduced by 20% from 1.071
		9: return 0.857  # Fruit 10 - reduced by 20% from 1.071
		10: return 1.012  # Fruit 11 - reduced by 15% from 1.19
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
		7: return 0.45  # Level 7 - extremely tight for left/right
		8: return 1.15  # Grape Medusa - larger to fully cover sprite with legs (was 0.95)
		9: return 0.92  # Crocodile Pen - increased from 0.85 to prevent clipping
		10: return 0.87  # Zebra/Watermelon - tighter
		_: return 1.0  # Default - no change
