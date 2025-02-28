extends Node2D

var street_1_scene = preload("res://Map/Streets/street_1.tmx")
var street_2_scene = preload("res://Map/Streets/street_2.tmx")
var street_2_edge_scene = preload("res://Map/Streets/street_2_edge.tmx")
var street_3_scene = preload("res://Map/Streets/street_3.tmx")
var street_4_scene = preload("res://Map/Streets/street_4.tmx")

@onready var map_foreground = $map/Background
var map_matrix = GlobalTileBase.current_map_matrix
var chunk_matrix = GlobalTileBase.current_chunk_matrix

var streets_insts: Array

func _ready():
	GlobalTileBase.current_chunk = self
	for i in range(GlobalTileBase.CHUNK_SIZE_WORLD):
		var init_array = []
		init_array.resize(GlobalTileBase.CHUNK_SIZE_WORLD)
		init_array.fill(0)
		chunk_matrix.append(init_array)
	
	
func generate_chunk(continent_coords: Vector2i, map_coords: Vector2i):
	var chunk_map_matrix: Array[Array]
	var chunk_coords_index: Vector2i = map_coords / GlobalTileBase.CHUNK_SIZE_MAP
	var y_chunk_start_pos = chunk_coords_index.y * GlobalTileBase.CHUNK_SIZE_MAP
	var y_chunk_end_pos = y_chunk_start_pos + GlobalTileBase.CHUNK_SIZE_MAP
	var x_chunk_start_pos = chunk_coords_index.x * GlobalTileBase.CHUNK_SIZE_MAP
	var x_chunk_end_pos = x_chunk_start_pos + GlobalTileBase.CHUNK_SIZE_MAP
	for y in range(y_chunk_start_pos, y_chunk_end_pos):
		var ids = "row"
		for x in range(x_chunk_start_pos, x_chunk_end_pos):
			var y_chunk_start_pos_world = (y - y_chunk_start_pos) * GlobalTileBase.MAP_TO_WORLD_TILE_FACTOR
			var y_chunk_end_pos_world = y_chunk_start_pos_world + GlobalTileBase.MAP_TO_WORLD_TILE_FACTOR
			var x_chunk_start_pos_world = (x - x_chunk_start_pos) * GlobalTileBase.MAP_TO_WORLD_TILE_FACTOR
			var x_chunk_end_pos_world = x_chunk_start_pos_world + GlobalTileBase.MAP_TO_WORLD_TILE_FACTOR
			ids = str(ids, ", ", map_matrix[y][x])
			for y_chunk in range(y_chunk_start_pos_world, y_chunk_end_pos_world):
				for x_chunk in range(x_chunk_start_pos_world, x_chunk_end_pos_world):
					$world.set_cell(Vector2i(x_chunk, y_chunk), 1, Vector2i(0, 0))
			if map_matrix[y][x] < -1:
				streets_insts.append(street_4_scene.instantiate())
				streets_insts.back().position = GlobalTileBase.tileCoords_to_globalPos(Vector2i(x_chunk_start_pos_world, y_chunk_start_pos_world))
				add_child(streets_insts.back())
		print(ids)
	
func load_chunks():
	generate_chunk(GlobalTileBase.current_location_continent, GlobalTileBase.current_location_map)

func load_from_file(continent_coords: Vector2i, map_coords: Vector2i):
	print("Load specific chunk")
