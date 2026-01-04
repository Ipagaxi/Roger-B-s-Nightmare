extends Node2D

var street_1_scene = preload("res://Map/Streets/street_1.tmx")
var street_2_scene = preload("res://Map/Streets/street_2.tmx")
var street_2_edge_scene = preload("res://Map/Streets/street_2_edge.tmx")
var street_3_scene = preload("res://Map/Streets/street_3.tmx")
var street_4_scene = preload("res://Map/Streets/street_4.tmx")

var region_matrix = TilesInterface.region_matrix
var local_matrix = TilesInterface.local_matrix
var street_asset_size = TilesInterface.STREET_ASSET_SIZE_TILE

var streets_insts: Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func init(region_coords: Vector2i):
	var global_tile_coords = TilesInterface.get_global_tile_coords_of_local(region_coords)
	#for y_tile in range(TilesInterface.LOCAL_SIZE_TILES):
	#	for x_tile in range(TilesInterface.LOCAL_SIZE_TILES):
	#		#if y_tile == 0 || x_tile == 0 || y_tile == TilesInterface.LOCAL_SIZE_TILES-1 || x_tile == TilesInterface.LOCAL_SIZE_TILES-1:
	#		#	$TileMapLayer.set_cell(Vector2i(x_tile, y_tile) + global_tile_coords, 1, Vector2i(1, 0))
	#		#else:
	#		$TileMapLayer.set_cell(Vector2i(x_tile, y_tile) + global_tile_coords, 2, Vector2i(9, 1))
	# If current region tile is a street...
	if region_matrix[region_coords.y][region_coords.x] == -2:
		set_correct_street_asset(region_coords, global_tile_coords)
	elif region_matrix[region_coords.y][region_coords.x] <= -1:
		set_correct_street_asset(region_coords, global_tile_coords)
	elif region_matrix[region_coords.y][region_coords.x] > 1:
		var building_insts = Building.generate_building(region_coords)
		for inst in building_insts:
			add_child(inst)

func apply_variation(street_inst: Node2D):
	var street_asphalt_tilemap := street_inst.get_child(0)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(street_inst.position)# + variation_seed_offset
	var atlas_coords = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0)]
	var probabilities = [100, 0.5, 0.5, 0.1, 0.1];

	for cell in street_asphalt_tilemap.get_used_cells():

		if street_asphalt_tilemap.get_cell_atlas_coords(cell) == Vector2i.ZERO:
			var variant = atlas_coords[rng.rand_weighted(probabilities)]
			street_asphalt_tilemap.set_cell(
				cell,
				1,
				variant
			)

func set_correct_street_asset(region_coords: Vector2i, global_tile_coords: Vector2i):
	var top_street = false
	var bottom_street = false
	var left_street = false
	var right_street = false
	# Due to the rotation, the position needs to be corrected
	var position_correction = Vector2i(0, 0)

	var x = region_coords.x
	var y = region_coords.y
	if region_matrix[max(y-1, 0)][x] == -2 || region_matrix[max(y-1, 0)][x] <= -1:
		top_street = true
	if region_matrix[min(y+1, TilesInterface.REGION_SIZE_TILES-1)][x] == -2 || region_matrix[min(y+1, TilesInterface.REGION_SIZE_TILES-1)][x] <= -1:
		bottom_street = true
	if region_matrix[y][max(x-1, 0)] == -2 || region_matrix[y][max(x-1, 0)] <= -1:
		left_street = true
	if region_matrix[y][min(x+1, TilesInterface.REGION_SIZE_TILES-1)] == -2 || region_matrix[y][min(x+1, TilesInterface.REGION_SIZE_TILES-1)] <= -1:
		right_street = true


	# One exit
	if top_street and !bottom_street and !left_street and !right_street:
		var street_1_inst = street_1_scene.instantiate()
		street_1_inst.rotation_degrees = 180
		position_correction = TilesInterface.tileCoords_to_trueCoords(street_asset_size)
		streets_insts.append(street_1_inst)
	elif !top_street and bottom_street and !left_street and !right_street:
		var street_1_inst = street_1_scene.instantiate()
		position_correction = Vector2i(0, 0)
		streets_insts.append(street_1_inst)
	elif !top_street and !bottom_street and left_street and !right_street:
		var street_1_inst = street_1_scene.instantiate()
		street_1_inst.rotation_degrees = 90
		position_correction = TilesInterface.tileCoords_to_trueCoords(Vector2i(street_asset_size.x, 0))
		streets_insts.append(street_1_inst)
	elif !top_street and !bottom_street and !left_street and right_street:
		var street_1_inst = street_1_scene.instantiate()
		street_1_inst.rotation_degrees = 270
		position_correction = TilesInterface.tileCoords_to_trueCoords(Vector2i(0, street_asset_size.y))
		streets_insts.append(street_1_inst)
		
	# Two opposite exits
	elif top_street and bottom_street and !left_street and !right_street:
		var street_2_inst = street_2_scene.instantiate()
		position_correction = Vector2i(0, 0)
		streets_insts.append(street_2_inst)
	elif !top_street and !bottom_street and left_street and right_street:
		var street_2_inst = street_2_scene.instantiate()
		street_2_inst.rotation_degrees = 90
		position_correction = TilesInterface.tileCoords_to_trueCoords(Vector2i(street_asset_size.x, 0))
		streets_insts.append(street_2_inst)
		
	# Two edge exits
	elif top_street and !bottom_street and left_street and !right_street:
		var street_2_edge_inst = street_2_edge_scene.instantiate()
		street_2_edge_inst.rotation_degrees = 270
		position_correction = TilesInterface.tileCoords_to_trueCoords(Vector2i(0, street_asset_size.y))
		streets_insts.append(street_2_edge_inst)
	elif top_street and !bottom_street and !left_street and right_street:
		var street_2_edge_inst = street_2_edge_scene.instantiate()
		position_correction = Vector2i(0, 0)
		streets_insts.append(street_2_edge_inst)
	elif !top_street and bottom_street and left_street and !right_street:
		var street_2_edge_inst = street_2_edge_scene.instantiate()
		street_2_edge_inst.rotation_degrees = 180
		position_correction = TilesInterface.tileCoords_to_trueCoords(street_asset_size)
		streets_insts.append(street_2_edge_inst)
	elif !top_street and bottom_street and !left_street and right_street:
		var street_2_edge_inst = street_2_edge_scene.instantiate()
		street_2_edge_inst.rotation_degrees = 90
		position_correction = TilesInterface.tileCoords_to_trueCoords(Vector2i(street_asset_size.x, 0))
		streets_insts.append(street_2_edge_inst)
		
	# Three exits
	elif top_street and !bottom_street and left_street and right_street:
		var street_3_inst = street_3_scene.instantiate()
		position_correction = Vector2i(0, 0)
		streets_insts.append(street_3_inst)
	elif top_street and bottom_street and !left_street and right_street:
		var street_3_inst = street_3_scene.instantiate()
		street_3_inst.rotation_degrees = 90
		position_correction = TilesInterface.tileCoords_to_trueCoords(Vector2i(street_asset_size.x, 0))
		streets_insts.append(street_3_inst)
	elif !top_street and bottom_street and left_street and right_street:
		var street_3_inst = street_3_scene.instantiate()
		street_3_inst.rotation_degrees = 180
		position_correction = TilesInterface.tileCoords_to_trueCoords(street_asset_size)
		streets_insts.append(street_3_inst)
	elif top_street and bottom_street and left_street and !right_street:
		var street_3_inst = street_3_scene.instantiate()
		street_3_inst.rotation_degrees = 270
		position_correction = TilesInterface.tileCoords_to_trueCoords(Vector2i(0, street_asset_size.y))
		streets_insts.append(street_3_inst)
	# Four exits
	elif top_street and bottom_street and left_street and right_street:
		var street_4_inst = street_4_scene.instantiate()
		streets_insts.append(street_4_inst)
	else:
		print("Problem with placing center street")
	
	var street_position = (TilesInterface.LOCAL_SIZE_TILES-street_asset_size.x)/2
	#for cell in streets_insts.back().get_used_cells():
	#	print(cell, ": ", streets_insts.back().get_cell_atlas_coords(cell))
	streets_insts.back().position = TilesInterface.tileCoords_to_trueCoords(global_tile_coords) + position_correction
	apply_variation(streets_insts.back())
	add_child(streets_insts.back())
