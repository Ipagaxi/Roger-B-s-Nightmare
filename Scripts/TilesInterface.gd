extends Node

# World Layers
# 1. Continent Layer
# 2. Region Layer (City)
# 3. Local Layer

# The local layer consist of multiple chunks

const TILE_SIZE = 32
const STREET_ASSET_SIZE_TILE = Vector2i(63, 63)

const LOCAL_SIZE_TILES = 63

const REGION_SIZE_TILES = 250

# Further size specifications are made in tiles 
const CONTINENT_SIZE_TILES_WIDTH = 100
const CONTINENT_SIZE_TILES_HEIGHT = 100


const CONTINENT_WIDTH_IN_LOCAL_TILES = CONTINENT_SIZE_TILES_WIDTH * REGION_SIZE_TILES * LOCAL_SIZE_TILES
const CONTINENT_HEIGHT_IN_LOCAL_TILES = CONTINENT_SIZE_TILES_HEIGHT * REGION_SIZE_TILES * LOCAL_SIZE_TILES

# CHUNK_SIZE in world tiles
#const CHUNK_SIZE_ON_LOCAL = 200
#const CHUNK_SIZE_ON_REGION: int = CHUNK_SIZE_ON_LOCAL / REGION_TO_LOCAL_TILE_FACTOR
#const CHUNK_SIZE_ON_CONTINENT: float = CHUNK_SIZE_ON_REGION / CONTINENT_TO_REGION_TILE_FACTOR

var current_location_continent: Vector2i
var current_location_region: Vector2i
var current_location_local: Vector2i

var region_spawn_location = Vector2i.ZERO

var continent_matrix: Array[Array]
# continent_matrix_loaded stores for every region if it is already loaded
var continent_matrix_loaded: Array[Array]
# all_region_matrices is a continent matrix where each cell is a region_matrix
var continent_region_matrices: Array[Array]
# The region_matrix of the current continent tile
var region_matrix: Array[Array]
# The chunk_matrix of the current chunk
var local_matrix: Array[Array]

var current_local = null

const INPUTS = {"right": Vector2.RIGHT,
				"left": Vector2.LEFT,
				"up": Vector2.UP,
				"down": Vector2.DOWN,
				"top_left": Vector2(-1, -1),
				"top_right": Vector2(1, -1),
				"bottom_left": Vector2(-1, 1),
				"bottom_right": Vector2(1, 1),
				"stay": Vector2i.ZERO}

func move(direction, body) -> Vector2i:
	var motion = TilesInterface.tileCoords_to_trueCoords(INPUTS[direction]) / 1.0
	var ray_up = body.get_node("BodyCollisionDetector").get_node("RayUp")
	var ray_top_right = body.get_node("BodyCollisionDetector").get_node("RayTopRight")
	var ray_right = body.get_node("BodyCollisionDetector").get_node("RayRight")
	var ray_bottom_right = body.get_node("BodyCollisionDetector").get_node("RayBottomRight")
	var ray_down = body.get_node("BodyCollisionDetector").get_node("RayDown")
	var ray_bottom_left = body.get_node("BodyCollisionDetector").get_node("RayBottomLeft")
	var ray_left = body.get_node("BodyCollisionDetector").get_node("RayLeft")
	var ray_top_left = body.get_node("BodyCollisionDetector").get_node("RayTopLeft")
	#for ray in body.get_node("BodyCollisionDetector").get_children():
	#	print("ray is colliding: ", ray.is_colliding())
	#	print("ray rotation: ", ray.rotation, ", motion angle: ", motion.angle())
	#	if ray.is_colliding() and motion.angle() == ray.rotation:
	#		print("Collision!")
	#		return body.global_position
	#print("#######################")
	
	
	#if body.test_move(body.transform, motion):
	if ray_up.is_colliding() and direction == "up":
		return body.global_position
	elif ray_top_right.is_colliding() and direction == "top_right":
		return body.global_position
	elif ray_right.is_colliding() and direction == "right":
		return body.global_position
	elif ray_bottom_right.is_colliding() and direction == "bottom_right":
		return body.global_position
	elif ray_down.is_colliding() and direction == "down":
		return body.global_position
	elif ray_bottom_left.is_colliding() and direction == "bottom_left":
		return body.global_position
	elif ray_left.is_colliding() and direction == "left":
		return body.global_position
	elif ray_top_left.is_colliding() and direction == "top_left":
		return body.global_position
	#body.move_and_collide(motion, false, 0.0, true)
	body.global_position += motion
	return body.global_position
	#var cell_data = current_chunk.get_node("house").get_node("Foreground").get_cell_tile_data(globalPos_to_tileCoords(new_pos))
	#if !cell_data:
	#	body.position = new_pos
	#else:
	#	if cell_data.get_meta("Passable"):
	#		body.position = new_pos

func tileCoords_to_trueCoords(position: Vector2i) -> Vector2i:
	return position * TILE_SIZE
	
func trueCoords_to_tileCoords(position: Vector2i) -> Vector2i:
	return position / TILE_SIZE

# It is a little bit confusing: the local is provided via region_coords (coords in the current region)
func get_global_tile_coords_of_local(region_coords: Vector2i, continent_coords: Vector2i) -> Vector2i:
	return continent_coords * REGION_SIZE_TILES * LOCAL_SIZE_TILES + region_coords * LOCAL_SIZE_TILES
	
func get_location_region(global_tile_coords: Vector2i) -> Vector2i:
	var location_region_in_local_tiles = global_tile_coords - (current_location_continent * REGION_SIZE_TILES * LOCAL_SIZE_TILES)
	return location_region_in_local_tiles / LOCAL_SIZE_TILES
	
func get_location_continent(global_tile_coords: Vector2i) -> Vector2i:
	var tile_size_of_one_region = REGION_SIZE_TILES*LOCAL_SIZE_TILES
	@warning_ignore("integer_division")
	return Vector2i(global_tile_coords.x / tile_size_of_one_region, global_tile_coords.y / tile_size_of_one_region)
	
func update_layer_positions(global_tile_coords: Vector2i):
	# The order in which to update is important!
	current_location_continent = get_location_continent(global_tile_coords)
	current_location_region = get_location_region(global_tile_coords);
	current_location_local = Vector2i(posmod(global_tile_coords.x, LOCAL_SIZE_TILES), posmod(global_tile_coords.y, LOCAL_SIZE_TILES))
