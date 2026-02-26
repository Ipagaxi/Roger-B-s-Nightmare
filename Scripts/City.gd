extends Node2D

const tileset_file_name = Global.TILESET_FILE_NAME
@onready var tileset = preload("res://assets/Tilesets/" + tileset_file_name)



const region_size = TilesInterface.REGION_SIZE_TILES
const number_inner_centers = 2
var number_circular_centers = Global.NUMBER_CIRCULAR_CENTERS
var number_centers = number_circular_centers + number_inner_centers
const number_sec_level_centers = 5
var lower_boundary_center_ids = Global.LOWER_BOUNDARY_CENTER_IDS

var outgoing_street_coords: Array[Vector2i]

func _ready():
	$Map.tile_set = tileset

func generate_region() -> Array[Array]:
	thread.start(_generate_region_threaded)
	var region_matrix = thread.wait_to_finish()
	call_deferred("draw_region", region_matrix)
	return region_matrix
	
func _generate_region_threaded() -> Array[Array]:
	var region_matrix = generate_region_data()
	#call_deferred("_draw_region", region_matrix)
	return region_matrix
	
func generate_region_data() -> Array[Array]:
	var region_matrix: Array[Array]
	create_matrix()
	print("City matrix generated")
	while region_matrix.is_empty():
		print("Generate city map...")
		region_matrix = generate_city_map()
	print("Generated city map successfully!")
	set_spawn_location(region_matrix)
	print("Spawn location set")
	return region_matrix
	
func _draw_region(region_matrix: Array[Array]):
	print("Draw region...")
	for y in range(region_size):
		for x in range(region_size):
			$Map.set_cell(Vector2i(x, y), 1, get_atlas_coord(region_matrix[y][x]))

func create_matrix() -> Array[Array]:
	var region_matrix: Array[Array]
	for i in range(region_size):
		var init_array = []
		
		init_array.resize(region_size)
		
		init_array.fill(0)
		
		region_matrix.append(init_array)
	return region_matrix
		
# Voronoi Diagrams are used for city map generation
# Each city tile gets an identifier:
#### Area centers: 3 - number areas-1 + 3 
#### Not border cells: identifier of closest center
func generate_city_map() -> Array[Array]:
	var city_matrix = create_matrix()
	var half_region_size = region_size * 0.5
	var voronoi_area_centers = get_random_circular_coords(number_circular_centers, half_region_size*0.9, half_region_size*0.97, Vector2(half_region_size, half_region_size))
	var inner_centers = get_two_random_inner_center()
	voronoi_area_centers.append_array(inner_centers)
	var inner_voronoi_cells = {}
	var tmp_outgoing_street_coords: Array[Vector2i]
	for center in inner_centers:
		inner_voronoi_cells[center] = [center]
	
	for i in range(number_centers):
		city_matrix[voronoi_area_centers[i].y][voronoi_area_centers[i].x] = i+lower_boundary_center_ids

	# Create first level Voronoi regions
	for y in range(region_size):
		for x in range(region_size):
			if city_matrix[y][x] == 0:
				var closest_center = voronoi_area_centers[0]
				for center in voronoi_area_centers:
					if (center - Vector2i(x, y)).length() <= (closest_center - Vector2i(x, y)).length():
						closest_center = center
						# This step is a preperation to generate second level voronoi diagrams in these inner regions
						if inner_centers.has(closest_center):
							# If a tile of the inner area is to close to border return function and restart
							if x <= region_size * 0.05 || x >= region_size * 0.95 || y <= region_size * 0.05 || y >= region_size * 0.95:
								return []
							inner_voronoi_cells[closest_center].append(Vector2i(x, y))
						
				city_matrix[y][x] = city_matrix[closest_center.y][closest_center.x]
				if has_neighbour_of_diff_region(Vector2i(x, y), city_matrix):
					city_matrix[y][x] = -2
					if x == 0 or x == region_size-1 or y == 0 or y == region_size -1:
						tmp_outgoing_street_coords.append(Vector2i(x,y))
			# Set cell of city surrounding area
			#$Map.set_cell(Vector2i(x, y), 1, get_atlas_coord(city_matrix[y][x]))
				
	# Now create second level voronoi diagrams in inner regions
	var index = 0
	for cell in inner_voronoi_cells:
		var coords = inner_voronoi_cells[cell]
		for coord in coords:
			if city_matrix[coord.y][coord.x] != -2:
				city_matrix[coord.y][coord.x] = 0
			
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
					if voronoi_centers[index_ex].distance_to(random_center) < 30 and city_matrix[random_center.y][random_center.x] != -2:
						valid_center = false
				if valid_center:
					break
			city_matrix[random_center.y][random_center.x] = i+lower_boundary_center_ids+number_circular_centers
			voronoi_centers.append(random_center)
			voronoi_area_centers.append(random_center)
			
		for coord in coords:
			if city_matrix[coord.y][coord.x] == 0:
				var closest_center = voronoi_centers[0]
				for center in voronoi_centers:
					if center.distance_to(coord) <= closest_center.distance_to(coord):
						closest_center = center
						
				city_matrix[coord.y][coord.x] = city_matrix[closest_center.y][closest_center.x]
				if has_neighbour_of_diff_region(coord, city_matrix):
					city_matrix[coord.y][coord.x] = -1
				else:
					city_matrix[coord.y][coord.x] = decide_if_block_street_and_return_id(coord, closest_center, city_matrix)
			# Set cell of inner city area
			#$Map.set_cell(coord, 1, get_atlas_coord(city_matrix[coord.y][coord.x]))
			
	# Just for debugging purposes coloring the voronoi centers yellow
	#for center in voronoi_area_centers:
	#	$Map.set_cell(center, 1, Vector2i(0, 1))
	#TilesInterface.region_matrix = city_matrix
	tmp_outgoing_street_coords = merge_neighbouring_outgoing_street_coords(tmp_outgoing_street_coords, city_matrix)
	outgoing_street_coords = tmp_outgoing_street_coords
	return city_matrix
	
func get_number_neighbouring_street_tiles(coord: Vector2i, current_region_matrix: Array[Array]) -> int:
	var neighbour_counter = 0
	if coord.x > 0 and current_region_matrix[coord.y][coord.x-1] == -2:
		neighbour_counter += 1
	if coord.x < (region_size-1) and current_region_matrix[coord.y][coord.x+1] == -2:
		neighbour_counter += 1
	if coord.y > 0 and current_region_matrix[coord.y-1][coord.x] == -2:
		neighbour_counter += 1
	if coord.y < (region_size-1) and current_region_matrix[coord.y+1][coord.x] == -2:
		neighbour_counter += 1
	return neighbour_counter

# Delete the coords that have a neighbour that is connecting tile to outgoing street part
# e.g. street coords (2, 1), (2, 0), (1, 0) -> Two border tiles (2, 0) and (1, 0) but (2, 0) gets deleted
# because due to (2, 1) we know that (1, 0) is the connecting tile to the outgoing street part
func merge_neighbouring_outgoing_street_coords(tmp_outgoing_street_coords: Array[Vector2i], current_region_matrix: Array[Array]) -> Array[Vector2i]:
	var i = 0
	while i < len(tmp_outgoing_street_coords):
		if get_number_neighbouring_street_tiles(tmp_outgoing_street_coords[i], current_region_matrix) == 2:
			tmp_outgoing_street_coords.remove_at(i)
		else:
			i += 1
	return tmp_outgoing_street_coords
	
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

func set_spawn_location(region_matrix: Array[Array]):
	var invalid_house_spawn_location = true
	var location: Vector2i
	var current_location_continent = TilesInterface.current_location_continent
	while invalid_house_spawn_location:
		location.x = randi_range(0, region_size-1)
		location.y = randi_range(0, region_size-1)
		# spawn on street
		if region_matrix[location.y][location.x] == -2:
			invalid_house_spawn_location = false
	TilesInterface.current_location_region = location #outgoing_street_coords[randi_range(0, len(outgoing_street_coords)-1)]

func satisfy_diff_neighbour_condition(neighbour_cell_value: int, coords: Vector2i, city_matrix: Array[Array]) -> bool:
	return abs(neighbour_cell_value) != city_matrix[coords.y][coords.x] and neighbour_cell_value != 0 and neighbour_cell_value != -1 and neighbour_cell_value != -2
		
func has_neighbour_of_diff_region(coords: Vector2i, city_matrix: Array[Array]) -> bool:
	# top left
	var neighbout_cell_value = city_matrix[max(coords.y - 1, 0)][max(coords.x - 1, 0)]
	if satisfy_diff_neighbour_condition(neighbout_cell_value, coords, city_matrix):
		return true;
	# top mid
	neighbout_cell_value = city_matrix[max(coords.y - 1, 0)][coords.x]
	if satisfy_diff_neighbour_condition(neighbout_cell_value, coords, city_matrix):
		return true;
	# top right
	neighbout_cell_value = city_matrix[max(coords.y - 1, 0)][min(coords.x + 1, region_size-1)]
	if satisfy_diff_neighbour_condition(neighbout_cell_value, coords, city_matrix):
		return true;
	# left
	neighbout_cell_value = city_matrix[coords.y][max(coords.x - 1, 0)]
	if satisfy_diff_neighbour_condition(neighbout_cell_value, coords, city_matrix):
		return true;
	# right
	neighbout_cell_value = city_matrix[coords.y][min(coords.x + 1, region_size-1)]
	if satisfy_diff_neighbour_condition(neighbout_cell_value, coords, city_matrix):
		return true;
	# bottom left
	neighbout_cell_value = city_matrix[min(coords.y + 1, region_size-1)][max(coords.x - 1, 0)]
	if satisfy_diff_neighbour_condition(neighbout_cell_value, coords, city_matrix):
		return true;
	# bottom mid
	neighbout_cell_value = city_matrix[min(coords.y + 1, region_size-1)][coords.x]
	if satisfy_diff_neighbour_condition(neighbout_cell_value, coords, city_matrix):
		return true;
	# bottom right
	neighbout_cell_value = city_matrix[min(coords.y + 1, region_size-1)][min(coords.x + 1, region_size-1)]
	if satisfy_diff_neighbour_condition(neighbout_cell_value, coords, city_matrix):
		return true;
	return false

	
func decide_if_block_street_and_return_id(tile_coords: Vector2i, closest_center: Vector2i, city_matrix: Array[Array]) -> int:
	var rng = RandomNumberGenerator.new()
	rng.seed = city_matrix[closest_center.y][closest_center.x]
	if ((tile_coords.x - closest_center.x) % rng.randi_range(4, 9) == 0 or (tile_coords.y - closest_center.y) % rng.randi_range(4, 9) == 0) and tile_coords != closest_center:
		return city_matrix[tile_coords.y][tile_coords.x] * -1
	return city_matrix[tile_coords.y][tile_coords.x]

func get_atlas_coord(id) -> Vector2i:
	if id <= -3:
		# City block streets
		return Vector2i(5, 1)
	elif id == -2:
		# City surrounding roads
		return Vector2i(9, 1)
	elif id == -1:
		return Vector2i(0, 0)
	elif id < lower_boundary_center_ids+number_circular_centers:
		# Surrounding city areas (grassland)
		var rng := RandomNumberGenerator.new()
		var atlas_coords = [Vector2i(0, 5), Vector2i(1, 5), Vector2i(2, 5), Vector2i(0, 6), Vector2i(1, 6), Vector2i(2, 6), Vector2i(0, 7), Vector2i(1, 7), Vector2i(2, 7)]
		var probabilities = [1, 1, 1, 1, 0.1, 1, 1, 1, 1];
		var variant = atlas_coords[rng.rand_weighted(probabilities)]
		return variant
	elif id >= lower_boundary_center_ids+number_circular_centers:
		# Inner city building tiles
		return Vector2i(1, 1)
		
	return Vector2i(7, 0)
