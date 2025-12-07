extends Node2D

const size = TilesInterface.REGION_SIZE_TILES
const number_regions = 100

var region_matrix = TilesInterface.region_matrix

func _ready():
	create_matrix()
	generate_city_map()
	set_spawn_location()

func create_matrix():
	for i in range(size):
		var init_array = []
		init_array.resize(size)
		init_array.fill(0)
		region_matrix.append(init_array)
		
func generate_city_map():
	var voronoi_region_centers = []

	# scatter region centers until they are not too clumped
	for i in range(number_regions):
		var x_coord: int
		var y_coord: int
		while true:
			x_coord = randi_range(0, size-1)
			y_coord = randi_range(0, size-1)
			var too_close_to_others = false
			for index_ex in range(i):
				if (voronoi_region_centers[index_ex] - Vector2i(x_coord, y_coord)).length() < 5:
					too_close_to_others = true
			if !too_close_to_others:
				break


		region_matrix[y_coord][x_coord] = i+3
		voronoi_region_centers.append(Vector2i(x_coord, y_coord))

	# Create Voronoi regions
	for y in range(size):
		for x in range(size):
			if region_matrix[y][x] == 0:
				var closest_center = voronoi_region_centers[0]
				for center in voronoi_region_centers:
					if (center - Vector2i(x, y)).length() < (closest_center - Vector2i(x, y)).length():
						closest_center = center
				region_matrix[y][x] = region_matrix[closest_center.y][closest_center.x]
				if has_neighbour_of_diff_region(Vector2i(x, y), closest_center):
					region_matrix[y][x] = -2
					region_matrix[min(y+1, size-1)][min(x+1, size-1)] = -1
					region_matrix[min(y+1, size-1)][x] = -1
					region_matrix[min(y+1, size-1)][max(x-1, 0)] = -1
					region_matrix[y][min(x+1, size-1)] = -1
					region_matrix[y][max(x-1, 0)] = -1
					region_matrix[max(y-1, 0)][min(x+1, size-1)] = -1
					region_matrix[max(y-1, 0)][x] = -1
					region_matrix[max(y-1, 0)][max(x-1, 0)] = -1
				else:
					apply_block_pattern_to_city_district(Vector2i(x, y), closest_center)
			$Map.set_cell(Vector2i(x, y), 0, get_atlas_coord(region_matrix[y][x]))

func set_spawn_location():
	var invalid_house_spawn_location = true
	var location: Vector2i
	while invalid_house_spawn_location:
		location.x = randi_range(0, size-1)
		location.y = randi_range(0, size-1)
		if region_matrix[location.y][location.x] > 1:
			invalid_house_spawn_location = false
	TilesInterface.current_location_region = location

func satify_neighbour_condition(neighbour_cell_value: int, coords: Vector2i) -> bool:
	return abs(neighbour_cell_value) != region_matrix[coords.y][coords.x] and neighbour_cell_value != 0 and neighbour_cell_value != -1 and neighbour_cell_value != -2
		
func has_neighbour_of_diff_region(coords: Vector2i, closest_center: Vector2i) -> bool:
	# top left
	var neighbout_cell_value = region_matrix[max(coords.y - 1, 0)][max(coords.x - 1, 0)]
	if satify_neighbour_condition(neighbout_cell_value, coords):
		return true;
	# top mid
	neighbout_cell_value = region_matrix[max(coords.y - 1, 0)][coords.x]
	if satify_neighbour_condition(neighbout_cell_value, coords):
		return true;
	# top right
	neighbout_cell_value = region_matrix[max(coords.y - 1, 0)][min(coords.x + 1, size-1)]
	if satify_neighbour_condition(neighbout_cell_value, coords):
		return true;
	# left
	neighbout_cell_value = region_matrix[coords.y][max(coords.x - 1, 0)]
	if satify_neighbour_condition(neighbout_cell_value, coords):
		return true;
	# right
	neighbout_cell_value = region_matrix[coords.y][min(coords.x + 1, size-1)]
	if satify_neighbour_condition(neighbout_cell_value, coords):
		return true;
	# bottom left
	neighbout_cell_value = region_matrix[min(coords.y + 1, size-1)][max(coords.x - 1, 0)]
	if satify_neighbour_condition(neighbout_cell_value, coords):
		return true;
	# bottom mid
	neighbout_cell_value = region_matrix[min(coords.y + 1, size-1)][coords.x]
	if satify_neighbour_condition(neighbout_cell_value, coords):
		return true;
	# bottom right
	neighbout_cell_value = region_matrix[min(coords.y + 1, size-1)][min(coords.x + 1, size-1)]
	if satify_neighbour_condition(neighbout_cell_value, coords):
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
		return Vector2i(0, 1)
	elif id <= -1:
		return Vector2i(1, 1)
	elif id > 1:
		return Vector2i(0, 0)
		
	return Vector2i(0, 0)
