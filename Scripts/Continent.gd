extends Node2D

@onready var tilemap = $Map

const MAP_WIDTH = 100
const MAP_HEIGHT = 100
const TILE_SIZE = 32

func _ready():
	var noise = FastNoiseLite.new();
	
	# Set noise parameters
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_VALUE
	noise.frequency = 0.0015
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 1
	
	for x in range(MAP_WIDTH):
		for y in range(MAP_HEIGHT):
			var value = noise.get_noise_2d(x * 32, y * 32)  # Scale factor
			var tile_id = map_noise_to_tile_id(value)
			tilemap.set_cell(Vector2i(x, y), 0, tile_id)
	

func map_noise_to_tile_id(value) -> Vector2i:
	if value < -0.3:
		return Vector2i(1, 1)
	if value < -0.2:
		return Vector2i(0, 1)
	return Vector2i(0, 0)
