extends Node
class_name Utils

## Utils - Utility functions for the game

# Generate a simple circle texture for fruits (placeholder until we have real sprites)
static func generate_circle_texture(radius: int, color: Color) -> ImageTexture:
	var size = radius * 2
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)

	for x in range(size):
		for y in range(size):
			var dx = x - radius
			var dy = y - radius
			var distance = sqrt(dx * dx + dy * dy)

			if distance <= radius:
				# Create gradient for 3D effect
				var intensity = 1.0 - (distance / radius) * 0.3
				var pixel_color = Color(
					color.r * intensity,
					color.g * intensity,
					color.b * intensity,
					1.0
				)
				image.set_pixel(x, y, pixel_color)
			else:
				image.set_pixel(x, y, Color(0, 0, 0, 0))

	return ImageTexture.create_from_image(image)
