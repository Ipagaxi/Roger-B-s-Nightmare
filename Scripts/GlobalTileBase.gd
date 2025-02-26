extends Node

const TILE_SIZE = 32

const CONTINENT_TO_MAP_TILE_FACTOR = 50
const MAP_TO_WORLD_TILE_FACTOR = 50

# CHUNK_SIZE in world tiles
const CHUNK_SIZE_WORLD = 200
const CHUNK_SIZE_MAP: int = CHUNK_SIZE_WORLD / MAP_TO_WORLD_TILE_FACTOR
const CHUNK_SIZE_CONTINENT: float = CHUNK_SIZE_MAP / CONTINENT_TO_MAP_TILE_FACTOR

var current_continent_location: Vector2i
var current_map_location: Vector2i
var current_world_location: Vector2i

var map_spawn_location = Vector2i.ZERO

var continent_matrix: Array[Array]
# The map_matrix of the current continent tile
var current_map_matrix: Array[Array]
# The chunk_matrix of the current chunk
var current_chunk_matrix: Array[Array]

var current_chunk = null

const INPUTS = {"right": Vector2.RIGHT,
				"left": Vector2.LEFT,
				"up": Vector2.UP,
				"down": Vector2.DOWN,
				"top_left": Vector2(-1, -1),
				"top_right": Vector2(1, -1),
				"bottom_left": Vector2(-1, 1),
				"bottom_right": Vector2(1, 1),
				"stay": Vector2.ZERO}

func move(direction, body):
	var new_pos:Vector2i = body.position + INPUTS[direction] * TILE_SIZE
	var cell_data = current_chunk.get_node("map").get_node("Foreground").get_cell_tile_data(globalCoords_to_tilePos(new_pos))
	if !cell_data:
		body.position = new_pos
	else:
		if cell_data.get_meta("Passable"):
			body.position = new_pos


func tilePos_to_globalCoords(position: Vector2i) -> Vector2i:
	return position * TILE_SIZE
	
func globalCoords_to_tilePos(position: Vector2i) -> Vector2i:
	return position / TILE_SIZE
	
