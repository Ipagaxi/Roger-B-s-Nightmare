extends Node2D

@onready var city_scene = preload("res://Scenes/City.tscn")
@onready var outland_scene = preload("res://Scenes/RegionOutland.tscn")

var continent_matrix = TilesInterface.continent_matrix

var assigned_region

func _ready():
	pass # Replace with function body.

func generate(continent_coords: Vector2i):
	var region_matrix: Array[Array]
	var region_size = TilesInterface.REGION_SIZE_TILES
	if continent_matrix[continent_coords.y][continent_coords.x] == 1:
		pass
	elif continent_matrix[continent_coords.y][continent_coords.x] == 2:
		pass
	elif continent_matrix[continent_coords.y][continent_coords.x] <= 4:
		outland_scene = preload("res://Scenes/RegionOutland.tscn")
		var outland_inst = outland_scene.instantiate()
		region_matrix = outland_inst.generate()
		outland_inst.global_position = TilesInterface.tileCoords_to_trueCoords(continent_coords*region_size)
		assigned_region = outland_inst
		#add_child(outland_inst)
		
	elif continent_matrix[continent_coords.y][continent_coords.x] == 5:
		# Generate city region
		city_scene = preload("res://Scenes/City.tscn")
		var city_inst = city_scene.instantiate()
		region_matrix = city_inst.generate()
		city_inst.global_position = TilesInterface.tileCoords_to_trueCoords((continent_coords)*region_size)
		assigned_region = city_inst
		#add_child(city_inst)

	if TilesInterface.continent_region_matrices[continent_coords.y][continent_coords.x].is_empty():
		TilesInterface.continent_region_matrices[continent_coords.y][continent_coords.x] = region_matrix


func draw():
	if assigned_region:
		add_child(assigned_region)
		assigned_region.draw()
