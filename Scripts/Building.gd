extends Node

var building_premises_63x63 = preload("res://Map/Buildings/63x63/building_premises.tmx")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

	
func generate_building(region_coords: Vector2i, continent_coords: Vector2i) -> Array:
	var building_insts: Array
	var building_premises_inst = building_premises_63x63.instantiate()
	building_insts.append(building_premises_inst)
	building_insts.back().position = TilesInterface.tileCoords_to_trueCoords(TilesInterface.get_global_tile_coords_of_local(region_coords, continent_coords))
	return building_insts
