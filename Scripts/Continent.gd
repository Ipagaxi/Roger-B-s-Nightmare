extends Node2D

@onready var tilemap = $Map

const tileset_file_name = Global.TILESET_FILE_NAME
@onready var tileset = preload("res://assets/Tilesets/" + tileset_file_name)

const WIDTH = TilesInterface.CONTINENT_SIZE_TILES_WIDTH
const HEIGHT = TilesInterface.CONTINENT_SIZE_TILES_HEIGHT
const TILE_SIZE = 32

const NUM_CITIES = 4

var continent_matrix_loaded = TilesInterface.continent_matrix_loaded
var continent_region_matrices = TilesInterface.continent_region_matrices

var city_positions = []

func generate_continent():
	var continent_matrix = TilesInterface.continent_matrix
	init_continent_matrix()
	
	var noise = FastNoiseLite.new();
	
	# Set noise parameters
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_VALUE
	noise.frequency = 0.0015
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 1
	
	for x in range(WIDTH):
		for y in range(HEIGHT):
			var value = noise.get_noise_2d(x * 32, y * 32)  # Scale factor
			if value < -0.3:
				# Id 1 for water tile
				continent_matrix[y][x] = 1
			elif value < -0.2:
				# Id 2 for coast tile
				continent_matrix[y][x] = 2
			else:
				# Id 4 for land tile
				continent_matrix[y][x] = 4
			#tilemap.set_cell(Vector2i(x, y), 1, tile_id)
			
	set_cities()

func init_continent_matrix():
	var continent_matrix = TilesInterface.continent_matrix
	for i in range(HEIGHT):
		var init_array = []
		var init_array_loaded = []
		var init_array_region_matrices = []
		
		init_array.resize(WIDTH)
		init_array_loaded.resize(WIDTH)
		init_array_region_matrices.resize(WIDTH)
		
		init_array.fill(0)
		init_array_loaded.fill(0)
		init_array_region_matrices.fill([])
		
		continent_matrix.append(init_array)
		continent_matrix_loaded.append(init_array_loaded)
		continent_region_matrices.append(init_array_region_matrices)
			
func set_cities():
	var continent_matrix = TilesInterface.continent_matrix
	for i in range(NUM_CITIES):
		var x_coord: int
		var y_coord: int
		var not_suitable_tile = true
		while not_suitable_tile:
			x_coord = randi_range(0, WIDTH-1)
			y_coord = randi_range(0, HEIGHT-1)
			var is_on_land = continent_matrix[y_coord][x_coord] != 1
			if is_on_land:
				not_suitable_tile = false
				for index_ex in range(i):
					var too_close = (city_positions[index_ex] - Vector2i(x_coord, y_coord)).length() < 5
					if too_close:
						not_suitable_tile = true
		
		# Id 5 for city tile
		continent_matrix[y_coord][x_coord] = 5
		city_positions.append(Vector2i(x_coord, y_coord))
		#tilemap.set_cell(Vector2i(x_coord, y_coord), 1, Vector2i(0, 1))
		
	TilesInterface.current_location_continent = city_positions[randi_range(0, NUM_CITIES-1)]

func set_tile_id(value) -> Vector2i:
	if value == 1:
		# Id 1 for water tile
		return Vector2i(2, 1)
	elif value == 2:
		# Id 2 for coast tile
		return Vector2i(3, 5)
	elif value == 3:
		# Id 3 for road tile
		return Vector2i(5, 1)
	elif value == 4:
		# id 4 for land tile
		return Vector2i(0, 6)
	elif value == 5:
		# id 5 for city tile
		return Vector2i(0, 1)
	else:
		# should not be reached
		return Vector2i(0, 6)
		
func get_a_star_cell_id(coords: Vector2) -> int:
	return coords.y * TilesInterface.CONTINENT_SIZE_TILES_WIDTH + coords.x
		
func set_city_connecting_roads():
	var continent_matrix = TilesInterface.continent_matrix
	var continent_height = TilesInterface.CONTINENT_SIZE_TILES_HEIGHT
	var continent_width = TilesInterface.CONTINENT_SIZE_TILES_WIDTH
	var a_star = AStar2D.new()
	a_star.reserve_space(continent_height * continent_width)
	for y in continent_height:
		for x in continent_width:
			# Only include not water region
			if continent_matrix[y][x] != 1:
				var idx = get_a_star_cell_id(Vector2(x, y))
				a_star.add_point(idx, Vector2(x, y))
				if y > 0 and a_star.has_point(get_a_star_cell_id(Vector2(x, y-1))):
					a_star.connect_points(idx, get_a_star_cell_id(Vector2(x, y-1)))
				if x > 0 and a_star.has_point(get_a_star_cell_id(Vector2(x-1, y))):
					a_star.connect_points(idx, get_a_star_cell_id(Vector2(x-1, y)))
					
	for i_1 in range(len(city_positions)):
		for i_2 in range(i_1, len(city_positions)):
			var path_points = a_star.get_point_path(get_a_star_cell_id(city_positions[i_1]), get_a_star_cell_id(city_positions[i_2]))
			for coord in path_points:
				if not city_positions.has(coord):
					continent_matrix[coord.y][coord.x] = 3
					#tilemap.set_cell(coord, 1, Vector2i(5, 1))
					
	#for coord in city_positions:
		#tilemap.set_cell(coord, 1, Vector2i(0, 1))
	
	
	#for i in range(len(city_positions)):
	#	a_star.add_point(i, city_positions[i])


func draw():
	var continent_matrix = TilesInterface.continent_matrix
	$Map.tile_set = tileset
	for y in range(WIDTH):
		for x in range(HEIGHT):
			$Map.set_cell(Vector2i(x, y), 1, set_tile_id(continent_matrix[y][x]))
