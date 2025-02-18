extends Node2D

const size = 500
const number_regions = 200

var map_matrix: Array[Array]

func _ready():
	create_matrix()
	generate_random_matrix()


func create_matrix():
	for i in range(size):
		var init_array = []
		init_array.resize(size)
		init_array.fill(0)
		map_matrix.append(init_array)
	
	
func satify_neighbour_condition(neighbour_cell_value: int, coords: Vector2i) -> bool:
	return abs(neighbour_cell_value) != map_matrix[coords.y][coords.x] and neighbour_cell_value != 0 and neighbour_cell_value != -1
		
func has_neighbour_of_diff_region(coords: Vector2i, closest_center: Vector2i) -> bool:
	# top left
	var neighbout_cell_value = map_matrix[max(coords.y - 1, 0)][max(coords.x - 1, 0)]
	if satify_neighbour_condition(neighbout_cell_value, coords):
		return true;
	# top mid
	neighbout_cell_value = map_matrix[max(coords.y - 1, 0)][coords.x]
	if satify_neighbour_condition(neighbout_cell_value, coords):
		return true;
	# top right
	neighbout_cell_value = map_matrix[max(coords.y - 1, 0)][min(coords.x + 1, size-1)]
	if satify_neighbour_condition(neighbout_cell_value, coords):
		return true;
	# left
	neighbout_cell_value = map_matrix[coords.y][max(coords.x - 1, 0)]
	if satify_neighbour_condition(neighbout_cell_value, coords):
		return true;
	# right
	neighbout_cell_value = map_matrix[coords.y][min(coords.x + 1, size-1)]
	if satify_neighbour_condition(neighbout_cell_value, coords):
		return true;
	# bottom left
	neighbout_cell_value = map_matrix[min(coords.y + 1, size-1)][max(coords.x - 1, 0)]
	if satify_neighbour_condition(neighbout_cell_value, coords):
		return true;
	# bottom mid
	neighbout_cell_value = map_matrix[min(coords.y + 1, size-1)][coords.x]
	if satify_neighbour_condition(neighbout_cell_value, coords):
		return true;
	# bottom right
	neighbout_cell_value = map_matrix[min(coords.y + 1, size-1)][min(coords.x + 1, size-1)]
	if satify_neighbour_condition(neighbout_cell_value, coords):
		return true;
	return false
	
func apply_block_pattern_to_city_district(tile_coords: Vector2i, closest_center: Vector2i):
	var rng = RandomNumberGenerator.new()
	rng.seed = map_matrix[closest_center.y][closest_center.x]
	if ((tile_coords.x - closest_center.x) % rng.randi_range(4, 9) == 0 or (tile_coords.y - closest_center.y) % rng.randi_range(4, 9) == 0) and tile_coords != closest_center:
		map_matrix[tile_coords.y][tile_coords.x] *= -1
	
func generate_random_matrix():
	var voronoi_region_centers = []
	
	for i in range(number_regions):
		var x_coord = randi_range(0, size-1)
		var y_coord = randi_range(0, size-1)
		map_matrix[y_coord][x_coord] = i+2
		voronoi_region_centers.append(Vector2i(x_coord, y_coord))

	# Create Voronoi regions
	for y in range(size):
		for x in range(size):
			if map_matrix[y][x] == 0:
				var closest_center = voronoi_region_centers[0]
				for center in voronoi_region_centers:
					if (center - Vector2i(x, y)).length() < (closest_center - Vector2i(x, y)).length():
						closest_center = center
				map_matrix[y][x] = map_matrix[closest_center.y][closest_center.x]
				print("set (", x, ", ", y, ") to ", map_matrix[closest_center.y][closest_center.x])
				if has_neighbour_of_diff_region(Vector2i(x, y), closest_center):
					map_matrix[y][x] = -1
					map_matrix[min(y+1, size-1)][min(x+1, size-1)] = -1
					map_matrix[min(y+1, size-1)][x] = -1
					map_matrix[min(y+1, size-1)][max(x-1, 0)] = -1
					map_matrix[y][min(x+1, size-1)] = -1
					map_matrix[y][max(x-1, 0)] = -1
					map_matrix[max(y-1, 0)][min(x+1, size-1)] = -1
					map_matrix[max(y-1, 0)][x] = -1
					map_matrix[max(y-1, 0)][max(x-1, 0)] = -1
				else:
					apply_block_pattern_to_city_district(Vector2i(x, y), closest_center)
			$Map.set_cell(Vector2i(x, y), 0, get_atlas_coord(map_matrix[y][x]))


func get_atlas_coord(id) -> Vector2i:
	if id == -1:
		return Vector2i(1, 1)
	if id <= -2:
		return Vector2i(1, 0)
	if id > 1:
		return Vector2i(0, 0)
		
	return Vector2i(0, 0)
