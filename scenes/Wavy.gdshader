shader_type canvas_item;

uniform float speed : hint_range(-10, 10) = 1.0;
uniform vec2 direction;
uniform vec2 tiling;

void fragment() {
	// Get the screen coordinates for the current pixel.
	vec2 screen_uv = vec2(SCREEN_UV.x * tiling.x, SCREEN_UV.y * tiling.y);

	// Calculate the offset using a sine wave to create a back-and-forth motion.
	float offset = sin(TIME * speed) * 5.1;

	// Add the offset to the X coordinate of the screen UV.
	screen_uv.x += offset * direction.x;
	screen_uv.y += offset * direction.y;

	// Sample the texture at the new screen UV coordinates.
	COLOR = texture(TEXTURE, screen_uv);
}
