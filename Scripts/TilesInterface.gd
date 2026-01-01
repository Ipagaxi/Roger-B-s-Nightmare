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
# The region_matrix of the current continent tile
var region_matrix: Array[Array]
# region_matrix_loaded holds for every region if it is already loaded
var region_matrix_loaded: Array[Array]
# The chunk_matrix of the current chunk
var local_matrix: Array[Array]

var current_local = null

var current_layer_id = 0

const INPUTS = {"right": Vector2.RIGHT,
				"left": Vector2.LEFT,
				"up": Vector2.UP,
				"down": Vector2.DOWN,
				"top_left": Vector2(-1, -1),
				"top_right": Vector2(1, -1),
				"bottom_left": Vector2(-1, 1),
				"bottom_right": Vector2(1, 1),
				"stay": Vector2.ZERO}

func move(direction, body) -> Vector2i:
	var new_pos: Vector2i = body.position + INPUTS[direction] * TILE_SIZE
	body.position = new_pos
	return new_pos
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
func get_global_tile_coords_of_local(region_coords: Vector2i) -> Vector2i:
	#var offset_x = (CONTINENT_SIZE_TILES_WIDTH * REGION_SIZE_TILES * LOCAL_SIZE_TILES) / 2
	#var offset_y = (CONTINENT_SIZE_TILES_HEIGHT * REGION_SIZE_TILES * LOCAL_SIZE_TILES) / 2
	return current_location_continent * REGION_SIZE_TILES * LOCAL_SIZE_TILES + region_coords * LOCAL_SIZE_TILES #- Vector2i(offset_x, offset_y)
	
func get_location_region(global_tile_coords: Vector2i) -> Vector2i:
	var location_region_in_local_tiles = global_tile_coords - (current_location_continent * REGION_SIZE_TILES * LOCAL_SIZE_TILES)
	return location_region_in_local_tiles / LOCAL_SIZE_TILES
