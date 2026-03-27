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

var move_animation_speed = 20

const INPUTS = {"right": Vector2.RIGHT,
				"left": Vector2.LEFT,
				"up": Vector2.UP,
				"down": Vector2.DOWN,
				"top_left": Vector2(-1, -1),
				"top_right": Vector2(1, -1),
				"bottom_left": Vector2(-1, 1),
				"bottom_right": Vector2(1, 1),
				"stay": Vector2i.ZERO}
				

# Moves the body from start to end with each call a step
# Returns if whole move finished
func move(start: Vector2, end: Vector2, delta: float, body) -> bool:
	var move_operator = body.get_node("MoveOperator")
	if not move_operator.moving:
		return true
	var distance = end - start
	var motion = Vector2(4, 4)*(distance/32)#(distance * delta*5.0).floor()
	var rest = end - body.global_position
	var finished_moving = false
	if motion.length() >= (rest).length():
		body.global_position = end
		finished_moving = true
	else:
		body.global_position += motion
	move_operator.moving = not finished_moving
	return finished_moving

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
