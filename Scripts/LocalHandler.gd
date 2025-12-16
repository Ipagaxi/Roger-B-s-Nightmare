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
	
func unload_local(region_coords: Vector2i):
	if loaded_locals.has(region_coords):
		loaded_locals[region_coords].queue_free()
		loaded_locals.erase(region_coords)

	
func load_locals():
	var num_locals_loading_in_each_dir = Global.NUM_LOCALS_LOADING_IN_EACH_DIRECTION
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
