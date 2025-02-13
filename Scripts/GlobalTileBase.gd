extends Node

const TILE_SIZE = 32

const INPUTS = {"right": Vector2.RIGHT,
				"left": Vector2.LEFT,
				"up": Vector2.UP,
				"down": Vector2.DOWN,
				"top_left": Vector2(-1, -1),
				"top_right": Vector2(1, -1),
				"bottom_left": Vector2(-1, 1),
				"bottom_right": Vector2(1, 1),
				"stay": Vector2.ZERO}
				
func move(direction) -> Vector2:
	return INPUTS[direction] * TILE_SIZE
	
func map_position(position: Vector2) -> Vector2:
	return position * TILE_SIZE
