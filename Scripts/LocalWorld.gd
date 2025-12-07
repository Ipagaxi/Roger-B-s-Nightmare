extends Node2D

var street_1_scene = preload("res://Map/Streets/street_1.tmx")
var street_2_scene = preload("res://Map/Streets/street_2.tmx")
var street_2_edge_scene = preload("res://Map/Streets/street_2_edge.tmx")
var street_3_scene = preload("res://Map/Streets/street_3.tmx")
var street_4_scene = preload("res://Map/Streets/street_4.tmx")

@onready var map_foreground = $map/Background
var region_matrix = TilesInterface.region_matrix
var local_matrix = TilesInterface.local_matrix

var streets_insts: Array

func _ready():
	TilesInterface.current_local = self
	for i in range(TilesInterface.LOCAL_SIZE_TILES):
		var init_array = []
		init_array.resize(TilesInterface.LOCAL_SIZE_TILES)
		init_array.fill(0)
		local_matrix.append(init_array)
	
	
func generate_local(region_coords: Vector2i):
	# Based on tile behind passed region_coords, local has to be generated
	
	for y_tile in range(TilesInterface.LOCAL_SIZE_TILES):
				for x_tile in range(TilesInterface.LOCAL_SIZE_TILES):
					$world.set_cell(Vector2i(x_tile, y_tile), 1, Vector2i(0, 0))
	
func load_locals():
	generate_local(TilesInterface.current_location_region)

func load_from_file(continent_coords: Vector2i, region_coords: Vector2i):
	print("Load specific chunk")
