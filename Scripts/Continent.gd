extends Node2D

@onready var tilemap = $Map

const WIDHT = 100
const HEIGHT = 100
const TILE_SIZE = 32

const NUM_CITIES = 4

var continent_matrix = GlobalTileBase.continent_matrix

func _ready():
    init_continent_matrix()
    
    var noise = FastNoiseLite.new();
    
    # Set noise parameters
    noise.seed = randi()
    noise.noise_type = FastNoiseLite.TYPE_VALUE
    noise.frequency = 0.0015
    noise.fractal_type = FastNoiseLite.FRACTAL_FBM
    noise.fractal_octaves = 1
    
    for x in range(WIDHT):
        for y in range(HEIGHT):
            var value = noise.get_noise_2d(x * 32, y * 32)  # Scale factor
            var tile_id = set_tile_id(value, x, y)
            tilemap.set_cell(Vector2i(x, y), 0, tile_id)
            
    set_cities()
            
func init_continent_matrix():
    for i in range(HEIGHT):
        var init_array = []
        init_array.resize(WIDHT)
        init_array.fill(0)
        continent_matrix.append(init_array)
            
func set_cities():
    var city_positions = []
    for i in range(NUM_CITIES):
        var x_coord: int
        var y_coord: int
        var not_suitable_tile = true
        while not_suitable_tile:
            x_coord = randi_range(0, WIDHT-1)
            y_coord = randi_range(0, HEIGHT-1)
            var is_on_land = continent_matrix[y_coord][x_coord] != 1
            if is_on_land:
                not_suitable_tile = false
                for index_ex in range(i):
                    var too_close = (city_positions[index_ex] - Vector2i(x_coord, y_coord)).length() < 5
                    if too_close:
                        not_suitable_tile = true
        
        # Id 4 for city tile
        continent_matrix[y_coord][x_coord] = 4
        city_positions.append(Vector2i(x_coord, y_coord))
        tilemap.set_cell(Vector2i(x_coord, y_coord), 0, Vector2i(1, 0))
        
    GlobalTileBase.current_continent_location = city_positions[randi_range(0, NUM_CITIES-1)]

func set_tile_id(value, x, y) -> Vector2i:
    if value < -0.3:
        # Id 1 for water tile
        continent_matrix[y][x] = 1
        return Vector2i(1, 1)
    elif value < -0.2:
        # Id 2 for coast tile
        continent_matrix[y][x] = 2
        return Vector2i(0, 1)
    else:
        # Id 3 for land tile
        continent_matrix[y][x] = 3
        return Vector2i(0, 0)
