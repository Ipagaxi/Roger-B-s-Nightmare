extends Node2D

const region_size = TilesInterface.REGION_SIZE_TILES
const number_inner_centers = 2
const number_circular_centers = 6
const number_centers = number_circular_centers + number_inner_centers
const number_sec_level_centers = 5

var region_matrix = TilesInterface.region_matrix
var region_matrix_loaded = TilesInterface.region_matrix_loaded

func _ready():
	create_matrix()
	print("City matrix generated")
	generate_city_map()
	print("Generated city map")
	set_spawn_location()
	print("Spawn location set")

func create_matrix():
	for i in range(region_size):
		var init_array = []
		var init_arrray_loaded = []
		
		init_array.resize(region_size)
		init_arrray_loaded.resize(region_size)
		
		init_array.fill(0)
		init_arrray_loaded.fill(false)
		
		region_matrix.append(init_array)
		region_matrix_loaded.append(init_arrray_loaded)
		
# Voronoi Diagrams are used for city map generation
# Each city tile gets an identifier:
#### Area centers: 3 - number areas-1 + 3 
#### Not border cells: identifier of closest center
func generate_city_map():
	var half_region_size = region_size * 0.5
	var voronoi_area_centers = get_random_circular_coords(number_circular_centers, half_region_size*0.9, half_region_size*0.97, Vector2(half_region_size, half_region_size))
	var inner_centers = get_two_random_inner_center()
	voronoi_area_centers.append_array(inner_centers)
	var inner_voronoi_cells = {}
	for center in inner_centers:
		inner_voronoi_cells[center] = [center]
	
	for i in range(number_centers):
		region_matrix[voronoi_area_centers[i].y][voronoi_area_centers[i].x] = i+3

	# Create first level Voronoi regions
	for y in range(region_size):
		for x in range(region_size):
			if region_matrix[y][x] == 0:
				var closest_center = voronoi_area_centers[0]
				for center in voronoi_area_centers:
					if (center - Vector2i(x, y)).length() <= (closest_center - Vector2i(x, y)).length():
						closest_center = center
						# This step is a preperation to generate second level voronoi diagrams in these inner regions
						if inner_centers.has(closest_center):
							inner_voronoi_cells[closest_center].append(Vector2i(x, y))
						
				region_matrix[y][x] = region_matrix[closest_center.y][closest_center.x]
				if has_neighbour_of_diff_region(Vector2i(x, y)):
					region_matrix[y][x] = -2
				#elif Vector2i(x, y).distance_to(closest_center) < 20:
				#	apply_block_pattern_to_city_district(Vector2i(x, y), closest_center)
			$Map.set_cell(Vector2i(x, y), 0, get_atlas_coord(region_matrix[y][x]))
	
	# Now create second level voronoi diagrams in inner regions
	var index = 0
	for cell in inner_voronoi_cells:
		var coords = inner_voronoi_cells[cell]
		for coord in coords:
			if region_matrix[coord.y][coord.x] != -2:
				region_matrix[coord.y][coord.x] = 0
			
		var voronoi_centers = []
		# scatter region centers until they are not too clumped
		var start = number_sec_level_centers*index
		var end = start+number_sec_level_centers
		for i in range(start, end):
			var random_center: Vector2i
			while true:
				random_center = coords.pick_random()
				var valid_center = true
				for index_ex in range(i):
					if voronoi_centers[index_ex].distance_to(random_center) < 30 and region_matrix[random_center.y][random_center.x] != -2:
						valid_center = false
				if valid_center:
					break
			region_matrix[random_center.y][random_center.x] = i+3
			voronoi_centers.append(random_center)
			voronoi_area_centers.append(random_center)
			
		for coord in coords:
			if region_matrix[coord.y][coord.x] == 0:
				var closest_center = voronoi_centers[0]
				for center in voronoi_centers:
					if center.distance_to(coord) <= closest_center.distance_to(coord):
						closest_center = center
						
				region_matrix[coord.y][coord.x] = region_matrix[closest_center.y][closest_center.x]
				if has_neighbour_of_diff_region(coord):
					region_matrix[coord.y][coord.x] = -1
				else:
					apply_block_pattern_to_city_district(coord, closest_center)
			$Map.set_cell(coord, 0, get_atlas_coord(region_matrix[coord.y][coord.x]))
			
	# Just for debugging purposes coloring the voronoi centers yellow
	for center in voronoi_area_centers:
		$Map.set_cell(center, 0, Vector2i(0, 1))

'''func add_block_streets_to_city():
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
			var tile_id = set_tile_id(value, x, y)
			tilemap.set_cell(Vector2i(x, y), 0, tile_id)'''


func get_random_circular_coords(num_values, min_radius, max_radius, offset: Vector2) -> Array[Vector2i]:
	var even_random_angles = get_random_evenly_distributed_angles(0, 2*PI, num_values)
	var random_vectors: Array[Vector2i] = []
	for i in range(num_values):
		var random_length = randi_range(min_radius, max_radius)
		var positioning_vector = Vector2.from_angle(even_random_angles[i]) * random_length + offset
		random_vectors.append(Vector2i(positioning_vector.round()))
	return random_vectors
	
func get_random_evenly_distributed_angles(min_val, max_val, samples) -> Array:
	var step = (max_val - min_val) / samples
	var result = []

	for i in range(samples):
		var start = min_val + step * i
		var end = start + step
		result.append(randf_range(start, end))
	return result
	
func get_two_random_inner_center() -> Array[Vector2i]:
	var map_offset = TilesInterface.REGION_SIZE_TILES / 2
	var random_angle = randf_range(0, 2*PI)
	var random_length = randf_range(region_size*0.1, region_size*0.15)
	var positioning_vector = Vector2.from_angle(random_angle) * random_length
	var int_vector = Vector2i(positioning_vector.round())
	var random_vectors: Array[Vector2i] = []
	random_vectors.append(int_vector + Vector2i(map_offset, map_offset))
	random_vectors.append(int_vector*(-1) + Vector2i(map_offset, map_offset))
	return random_vectors

func set_spawn_location():
	var invalid_house_spawn_location = true
	var location: Vector2i
	while invalid_house_spawn_location:
		location.x = randi_range(0, region_size-1)
		location.y = randi_range(0, region_size-1)
		# spawn on street
		if region_matrix[location.y][location.x] == -2:
			invalid_house_spawn_location = false
	TilesInterface.current_location_region = location

func satisfy_neighbour_condition(neighbour_cell_value: int, coords: Vector2i) -> bool:
	return abs(neighbour_cell_value) != region_matrix[coords.y][coords.x] and neighbour_cell_value != 0 and neighbour_cell_value != -1 and neighbour_cell_value != -2
		
func has_neighbour_of_diff_region(coords: Vector2i) -> bool:
	# top left
	var neighbout_cell_value = region_matrix[max(coords.y - 1, 0)][max(coords.x - 1, 0)]
	if satisfy_neighbour_condition(neighbout_cell_value, coords):
		return true;
	# top mid
	neighbout_cell_value = region_matrix[max(coords.y - 1, 0)][coords.x]
	if satisfy_neighbour_condition(neighbout_cell_value, coords):
		return true;
	# top right
	neighbout_cell_value = region_matrix[max(coords.y - 1, 0)][min(coords.x + 1, region_size-1)]
	if satisfy_neighbour_condition(neighbout_cell_value, coords):
		return true;
	# left
	neighbout_cell_value = region_matrix[coords.y][max(coords.x - 1, 0)]
	if satisfy_neighbour_condition(neighbout_cell_value, coords):
		return true;
	# right
	neighbout_cell_value = region_matrix[coords.y][min(coords.x + 1, region_size-1)]
	if satisfy_neighbour_condition(neighbout_cell_value, coords):
		return true;
	# bottom left
	neighbout_cell_value = region_matrix[min(coords.y + 1, region_size-1)][max(coords.x - 1, 0)]
	if satisfy_neighbour_condition(neighbout_cell_value, coords):
		return true;
	# bottom mid
	neighbout_cell_value = region_matrix[min(coords.y + 1, region_size-1)][coords.x]
	if satisfy_neighbour_condition(neighbout_cell_value, coords):
		return true;
	# bottom right
	neighbout_cell_value = region_matrix[min(coords.y + 1, region_size-1)][min(coords.x + 1, region_size-1)]
	if satisfy_neighbour_condition(neighbout_cell_value, coords):
		return true;
	return false

	
func apply_block_pattern_to_city_district(tile_coords: Vector2i, closest_center: Vector2i):
	var rng = RandomNumberGenerator.new()
	rng.seed = region_matrix[closest_center.y][closest_center.x]
	if ((tile_coords.x - closest_center.x) % rng.randi_range(4, 9) == 0 or (tile_coords.y - closest_center.y) % rng.randi_range(4, 9) == 0) and tile_coords != closest_center:
		region_matrix[tile_coords.y][tile_coords.x] *= -1

func get_atlas_coord(id) -> Vector2i:
	if id <= -3:
		return Vector2i(1, 0)
	elif id == -2:
		return Vector2i(1, 1)
	elif id == -1:
		return Vector2i(1, 1)
	elif id > 1:
		return Vector2i(0, 0)
		
	return Vector2i(0, 0)
