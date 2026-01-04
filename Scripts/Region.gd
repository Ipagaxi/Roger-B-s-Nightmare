extends Node2D

@onready var city_scene = preload("res://Scenes/City.tscn")

var continent_matrix = TilesInterface.continent_matrix
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(continent_coords: Vector2i):
	var current_location_continent = TilesInterface.current_location_continent
	var region_size = TilesInterface.REGION_SIZE_TILES
	if continent_matrix[continent_coords.y][continent_coords.x] == 1:
		pass
	elif continent_matrix[continent_coords.y][continent_coords.x] == 2:
		pass
	elif continent_matrix[continent_coords.y][continent_coords.x] == 3:
		pass
	elif continent_matrix[continent_coords.y][continent_coords.x] == 4:
		# Generate city region
		var city_inst = city_scene.instantiate()
		city_inst.global_position = TilesInterface.tileCoords_to_trueCoords((current_location_continent-continent_coords)*region_size)
		add_child(city_inst)
