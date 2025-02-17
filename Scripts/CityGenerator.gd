extends Node2D

const size = 500
const number_regions = 200

var map_matrix: Array[Array]

func _ready():
	create_matrix()
	generate_random_matrix()
	#create_tilemap()


func create_matrix():
	for i in range(size):
		var init_array = []
		init_array.resize(size)
		init_array.fill(-1)
		map_matrix.append(init_array)
		
func has_neighbour_of_diff_region(coords: Vector2i, closest_center: Vector2i) -> bool:
	#var direction = coords - closest_center
	#if abs(direction.x) < abs(direction.y):
	#	direction.x = 0
	#	direction.y = direction.y / max(abs(direction.y), 1)
	#else:
	#	direction.y = 0
	#	direction.x = direction.x / max(abs(direction.x), 1)
	#var outer_cell = Vector2i(min(max(coords.x + direction.x, 0), size-1), min(max(coords.y + direction.y, 0), size-1))
	#if abs(map_matrix[outer_cell.y][outer_cell.x]) != abs(map_matrix[coords.y][coords.x]) and map_matrix[outer_cell.y][outer_cell.x] != 10:
	#	return true;
	
	# top left
	var current_cell = map_matrix[min(max(coords.y - 1, 0), size-1)][min(max(coords.x - 1, 0), size-1)]
	if current_cell != map_matrix[coords.y][coords.x] and current_cell != -1 and current_cell != -2:
		return true;
	# top mid
	current_cell = map_matrix[min(max(coords.y - 1, 0), size-1)][min(max(coords.x , 0), size-1)]
	if current_cell != map_matrix[coords.y][coords.x] and current_cell != -1 and current_cell != -2:
		return true;
	# top right
	current_cell = map_matrix[min(max(coords.y - 1, 0), size-1)][min(max(coords.x + 1, 0), size-1)]
	if current_cell != map_matrix[coords.y][coords.x] and current_cell != -1 and current_cell != -2:
		return true;
	# left
	current_cell = map_matrix[min(max(coords.y, 0), size-1)][min(max(coords.x - 1, 0), size-1)]
	if current_cell != map_matrix[coords.y][coords.x] and current_cell != -1 and current_cell != -2:
		return true;
	# right
	current_cell = map_matrix[min(max(coords.y, 0), size-1)][min(max(coords.x + 1 , 0), size-1)]
	if current_cell != map_matrix[coords.y][coords.x] and current_cell != -1 and current_cell != -2:
		return true;
	# bottom left
	current_cell = map_matrix[min(max(coords.y + 1, 0), size-1)][min(max(coords.x - 1, 0), size-1)]
	if current_cell != map_matrix[coords.y][coords.x] and current_cell != -1 and current_cell != -2:
		return true;
	# bottom mid
	current_cell = map_matrix[min(max(coords.y + 1, 0), size-1)][min(max(coords.x , 0), size-1)]
	if current_cell != map_matrix[coords.y][coords.x] and current_cell != -1 and current_cell != -2:
		return true;
	# bottom right
	current_cell = map_matrix[min(max(coords.y + 1, 0), size-1)][min(max(coords.x + 1, 0), size-1)]
	if current_cell != map_matrix[coords.y][coords.x] and current_cell != -1 and current_cell != -2:
		return true;
	return false
	
	
func generate_random_matrix():
	var voronoi_region_centers = []
	for i in range(number_regions):
		var x_coord = randi_range(0, size-1)
		var y_coord = randi_range(0, size-1)
		map_matrix[y_coord][x_coord] = i
		voronoi_region_centers.append(Vector2i(x_coord, y_coord))
		
	# Create Voronoi regions
	for y in range(size):
		for x in range(size):
			var closest_center = voronoi_region_centers[0]
			for center in voronoi_region_centers:
				if (center - Vector2i(x, y)).length() < (closest_center - Vector2i(x, y)).length():
					closest_center = center
			map_matrix[y][x] = map_matrix[closest_center.y][closest_center.x]
			if has_neighbour_of_diff_region(Vector2i(x, y), closest_center):
				map_matrix[y][x] = -1
			elif ((x - closest_center.x) % 5 == 0 or (y - closest_center.y) % 9 == 0) and Vector2i(x, y) != closest_center:
				map_matrix[y][x] = -2
			$Map.set_cell(Vector2i(x, y), 0, get_atlas_coord(map_matrix[y][x]))
		
func create_tilemap():
	var map = $Map
	for y in range(size):
		for x in range(size):
			map.set_cell(Vector2i(x, y), 0, get_atlas_coord(map_matrix[y][x]))
			
	
			
func get_atlas_coord(id) -> Vector2i:
	if id == -1:
		return Vector2i(1, 1)
	if id == -2:
		return Vector2i(1, 0)
	if id == 1:
		return Vector2i(0, 0)
	if id == 2:
		return Vector2i(0, 0)
		
	return Vector2i(0, 0)
