extends Node2D

var grassland_scene = preload("res://Scenes/LocalLayer/LocalGrassland.tscn")
var building_scene = preload("res://Scenes/LocalLayer/LocalBuilding.tscn")
var street_scene = preload("res://Scenes/LocalLayer/LocalStreet.tscn")

const tileset_file_name = Global.TILESET_FILE_NAME
@onready var tileset = preload("res://assets/Tilesets/" + tileset_file_name)

var local_matrix = TilesInterface.local_matrix

var background_inst
var streets_insts: Array
var assigned_local

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TileMapLayer.tile_set = tileset

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func generate(region_coords: Vector2i, continent_coords: Vector2i):
	var region_matrix = TilesInterface.continent_region_matrices[continent_coords.y][continent_coords.x]
	if region_matrix.is_empty():
		print("region matrix is empty!")
		print(TilesInterface.continent_region_matrices)
	var global_tile_coords = TilesInterface.get_global_tile_coords_of_local(region_coords, continent_coords)
	background_inst = grassland_scene.instantiate()
	background_inst.position = TilesInterface.tileCoords_to_trueCoords(global_tile_coords)
	#add_child(grassland_inst)
	if region_matrix[region_coords.y][region_coords.x] == -2:
		# Generate road local
		assigned_local = street_scene.instantiate()
		assigned_local.generate(region_coords, continent_coords)
		assigned_local.position = TilesInterface.tileCoords_to_trueCoords(global_tile_coords)
	elif region_matrix[region_coords.y][region_coords.x] <= -1:
		# Generate block street local
		assigned_local = street_scene.instantiate()
		assigned_local.generate(region_coords, continent_coords)
		assigned_local.position = TilesInterface.tileCoords_to_trueCoords(global_tile_coords)
	elif region_matrix[region_coords.y][region_coords.x] >= Global.LOWER_BOUNDARY_CENTER_IDS+Global.NUMBER_CIRCULAR_CENTERS:
		# Generate building local
		assigned_local = building_scene.instantiate()
		assigned_local.generate()
		assigned_local.position = TilesInterface.tileCoords_to_trueCoords(global_tile_coords)
	elif region_matrix[region_coords.y][region_coords.x] >= Global.LOWER_BOUNDARY_CENTER_IDS:
		assigned_local = grassland_scene.instantiate()
		assigned_local.generate()
		assigned_local.position = TilesInterface.tileCoords_to_trueCoords(global_tile_coords)


func draw():
	if background_inst:
		add_child(background_inst)
	else:
		print("backgound_inst not instantiated!")
		
	if assigned_local:
		assigned_local.draw()
		add_child(assigned_local)
