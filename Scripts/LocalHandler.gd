extends Node2D

@onready var local_scene = preload("res://Scenes/Local.tscn")

var loaded_locals := {}

func _ready():
	load_locals()
	
	
func generate_local(region_coords: Vector2i):
	if loaded_locals.has(region_coords):
		return
	print("generate local: ", region_coords)
	TilesInterface.region_matrix_loaded[region_coords.y][region_coords.x] = true
	var local = local_scene.instantiate()
	add_child(local)
	local.init(region_coords)
	loaded_locals[region_coords] = local

func load_all_near_locals():
	var load_radius = Global.LOCAL_RADIUS
	var region_coords = TilesInterface.current_location_region
	for y in range(region_coords.y - load_radius, region_coords.y + load_radius + 1):
		for x in range(region_coords.x - load_radius, region_coords.x + load_radius + 1):
			var coords = Vector2i(x, y)
			if x < 0 or y < 0:
				continue
			if x >= TilesInterface.REGION_SIZE_TILES or y >= TilesInterface.REGION_SIZE_TILES:
				continue

			if coords.distance_to(region_coords) <= load_radius:
				generate_local(coords)
					
			
func unload_local(region_coords: Vector2i):
	if loaded_locals.has(region_coords):
		loaded_locals[region_coords].queue_free()
		loaded_locals.erase(region_coords)
		
func unload_all_far_away_locals():
	for local_coord in loaded_locals:
		if local_coord.distance_to(TilesInterface.current_location_region) > Global.LOCAL_RADIUS:
			unload_local(local_coord)

	
func load_locals():
	var num_locals_loading_in_each_dir = Global.LOCAL_RADIUS
	for y in range(num_locals_loading_in_each_dir*2 + 1):
		if TilesInterface.current_location_region.y+y-num_locals_loading_in_each_dir < 0:
			continue
		elif TilesInterface.current_location_region.y+y-num_locals_loading_in_each_dir >= TilesInterface.REGION_SIZE_TILES:
			break
		for x in range(num_locals_loading_in_each_dir*2 + 1):
			if TilesInterface.current_location_region.x+x-num_locals_loading_in_each_dir < 0:
				continue
			elif TilesInterface.current_location_region.x+x-num_locals_loading_in_each_dir >= TilesInterface.REGION_SIZE_TILES:
				break
			generate_local(Vector2i(TilesInterface.current_location_region.x+x-num_locals_loading_in_each_dir, TilesInterface.current_location_region.y+y-num_locals_loading_in_each_dir))
	TilesInterface.current_location_local = Vector2i(TilesInterface.LOCAL_SIZE_TILES, TilesInterface.LOCAL_SIZE_TILES)/2

func load_from_file(continent_coords: Vector2i, region_coords: Vector2i):
	print("Load specific chunk")
