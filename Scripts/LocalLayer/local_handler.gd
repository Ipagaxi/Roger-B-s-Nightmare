extends Node2D

# LocalHandler.gd manages when and how many Locals to (un-)load/generate
# whereas Local.gd manages which type of local to generate

@onready var local_scene = preload("res://Scenes/LocalLayer/Local.tscn")

var generated_locals := {}
var loaded_locals := {}
	

func generate_all_near_locals(continent_coords: Vector2i):
	var load_radius = Global.LOCAL_LOAD_RADIUS
	var region_coords = TilesInterface.current_location_region
	var region_size = TilesInterface.REGION_SIZE_TILES
	for y in range(region_coords.y - load_radius, region_coords.y + load_radius + 1):
		for x in range(region_coords.x - load_radius, region_coords.x + load_radius + 1):
			var coords = Vector2i(x, y)
			if coords.distance_to(region_coords) <= load_radius:
				# We use integer division to get the continent coordinates relative to the given one
				# Problem are negative numbers (e.g -3 / 250 = 0 and not -1),
				# therefore we shift the region coords by the size of a region in the positive space
				# (shifting by 1*region_size should be enough since it is unlikely that we will load so many locals at some point in the future
				# that locals from not only the neighbouring but also from the one behind need to be loaded)
				# Due to the shift we substract after the whole operation one so we get the correct offset
				@warning_ignore("integer_division")
				var continent_coords_offset = Vector2i((x+region_size) / region_size, (y+region_size) / region_size) - Vector2i(1, 1)
				var cont_coord = continent_coords + continent_coords_offset
				if (cont_coord.x < 0 or cont_coord.y < 0 or cont_coord.x >= TilesInterface.CONTINENT_SIZE_TILES_WIDTH or cont_coord.y >= TilesInterface.CONTINENT_SIZE_TILES_HEIGHT):
					continue
				var new_region_coords = Vector2i(posmod(coords.x, region_size), posmod(coords.y, region_size))
				var new_continent_coords = continent_coords+continent_coords_offset
				generate_local(new_region_coords, new_continent_coords)
	
func draw_all_near_locals():
	for item in generated_locals:
		if not loaded_locals.has(item):
			var local_inst = generated_locals[item]
			local_inst.draw()
			loaded_locals[item] = local_inst
			add_child(local_inst)

func generate_local(region_coords: Vector2i, continent_coords: Vector2i):
	if generated_locals.has([region_coords, continent_coords]):
		return
	local_scene = preload("res://Scenes/LocalLayer/Local.tscn")
	var local = local_scene.instantiate()
	local.generate(region_coords, continent_coords)
	generated_locals[[region_coords, continent_coords]] = local


func unload_local(region_coords: Vector2i, continent_coords: Vector2i):
	if loaded_locals.has([region_coords, continent_coords]):
		loaded_locals[[region_coords, continent_coords]].queue_free()
		loaded_locals.erase([region_coords, continent_coords])
		generated_locals.erase([region_coords, continent_coords])
		
func unload_all_far_away_locals():
	var current_location_region_global = TilesInterface.get_global_tile_coords_of_local(TilesInterface.current_location_region, TilesInterface.current_location_continent)
	var chunk_location_region_global: Vector2i
	for item in loaded_locals:
		chunk_location_region_global =  TilesInterface.get_global_tile_coords_of_local(item[0], item[1])
		if current_location_region_global.distance_to(chunk_location_region_global) > Global.LOCAL_UNLOAD_RADIUS*TilesInterface.LOCAL_SIZE_TILES:
			unload_local(item[0], item[1])

func load_from_file(continent_coords: Vector2i, region_coords: Vector2i):
	print("Load specific chunk")
