extends Node2D

@onready var region_scene = preload("res://Scenes/Region.tscn")

var generated_regions := {}
var loaded_regions := {}

# Called when the node enters the scene tree for the first time.
func _ready():
	#load_all_near_regions()
	pass


func generate_all_near_regions():
	var load_radius = Global.REGION_LOAD_RADIUS
	var continent_coords = TilesInterface.current_location_continent
	for y in range(continent_coords.y - load_radius, continent_coords.y + load_radius + 1):
		for x in range(continent_coords.x - load_radius, continent_coords.x + load_radius + 1):
			var coords = Vector2i(x, y)
			if x < 0 or y < 0:
				continue
			if x >= TilesInterface.CONTINENT_SIZE_TILES_WIDTH or y >= TilesInterface.CONTINENT_SIZE_TILES_HEIGHT:
				continue
			if coords.distance_to(continent_coords) <= load_radius:
				generate_region(coords)
				
func draw_all_near_regions():
	for region_coords in generated_regions:
		if not loaded_regions.has(region_coords):
			var region_inst = generated_regions[region_coords]
			add_child(region_inst)
			region_inst.draw()
			loaded_regions[region_coords] = region_inst

func generate_region(continent_coords: Vector2i):
	if generated_regions.has(continent_coords):
		return
	TilesInterface.continent_matrix_loaded[continent_coords.y][continent_coords.x] = true
	region_scene = preload("res://Scenes/Region.tscn")
	var region = region_scene.instantiate()
	#add_child(region)
	region.generate(continent_coords)
	generated_regions[continent_coords] = region


func unload_region(continent_coords: Vector2i):
	if loaded_regions.has(continent_coords):
		loaded_regions[continent_coords].queue_free()
		loaded_regions.erase(continent_coords)
		generated_regions.erase(continent_coords)

func unload_all_far_away_regions():
	for region_coord in loaded_regions:
		if region_coord.distance_to(TilesInterface.current_location_continent) > Global.REGION_UNLOAD_RADIUS:
			unload_region(region_coord)


func load_from_file(continent_coords: Vector2i, region_coords: Vector2i):
	print("Load specific chunk")
