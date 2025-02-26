extends Node2D

const size = 30
const number_regions = 9

var map_matrix: Array[Array]

func _ready():
	create_matrix()
	generate_random_matrix()
	create_tilemap()


func create_matrix():
	for i in range(size):
		var init_array = []
		init_array.resize(size)
		init_array.fill(-1)
		map_matrix.append(init_array)
		
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
		
func create_tilemap():
	var map = $Map
	for y in range(size):
		for x in range(size):
			map.set_cell(Vector2i(x, y), 0, get_atlas_coord(map_matrix[y][x]))
			
	
			
func get_atlas_coord(id) -> Vector2i:
	if id == 1:
		return Vector2i(0, 6)
	if id == 2:
		return Vector2i(4, 15)
	if id == 3:
		return Vector2i(0, 42)
	if id == 4:
		return Vector2i(0, 55)
	if id == 5:
		return Vector2i(0, 60)
	if id == 6:
		return Vector2i(0, 65)
	if id == 7:
		return Vector2i(0, 70)
	if id == 8:
		return Vector2i(0, 95)
		
	return Vector2i.ZERO
	
