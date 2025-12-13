extends Node2D

var street_1_scene = preload("res://Map/Streets/street_1.tmx")
var street_2_scene = preload("res://Map/Streets/street_2.tmx")
var street_2_edge_scene = preload("res://Map/Streets/street_2_edge.tmx")
var street_3_scene = preload("res://Map/Streets/street_3.tmx")
var street_4_scene = preload("res://Map/Streets/street_4.tmx")

@onready var map_foreground = $map/Background
var region_matrix = TilesInterface.region_matrix
var local_matrix = TilesInterface.local_matrix
var street_asset_size = TilesInterface.STREET_ASSET_SIZE_TILE

var streets_insts: Array

func _ready():
	TilesInterface.current_local = self
	for i in range(TilesInterface.LOCAL_SIZE_TILES):
		var init_array = []
		init_array.resize(TilesInterface.LOCAL_SIZE_TILES)
		init_array.fill(0)
		local_matrix.append(init_array)
	load_locals()
	
	
func generate_local(region_coords: Vector2i):
	# Based on tile behind passed region_coords, local has to be generated
	var offset_to_current_position_region = (region_coords - TilesInterface.current_location_region) * TilesInterface.LOCAL_SIZE_TILES
	for y_tile in range(TilesInterface.LOCAL_SIZE_TILES):
		for x_tile in range(TilesInterface.LOCAL_SIZE_TILES):
			$world.set_cell(Vector2i(x_tile, y_tile) + offset_to_current_position_region, 1, Vector2i(0, 0))
	# If current region tile is a street...
	if region_matrix[region_coords.y][region_coords.x] == -2:
		set_correct_street_asset(region_coords, offset_to_current_position_region)

func add_vertically_streets_from_center_to_local_border(starting_y_coord: int, offset_to_current_position_region: Vector2i):
	# center_index gives the index of the center street in terms how many street assets fit in the local
	var center_index = TilesInterface.STREET_ASSET_LOCAL_SIZE_FACTOR / 2
	for i in range(center_index):
		var street_2_filler_inst = street_2_scene.instantiate()
		streets_insts.append(street_2_filler_inst)
		streets_insts.back().position = TilesInterface.tileCoords_to_trueCoords(Vector2i(center_index*street_asset_size.x, starting_y_coord + street_asset_size.y*i) + offset_to_current_position_region)
		add_child(streets_insts.back())
		
func add_horizontally_streets_from_center_to_local_border(starting_x_coord: int, offset_to_current_position_region: Vector2i):
	# center_street_index gives the index of the center street in terms how many street assets fit in the local
	var center_index = TilesInterface.STREET_ASSET_LOCAL_SIZE_FACTOR / 2
	var position_correction = TilesInterface.tileCoords_to_trueCoords(Vector2i(street_asset_size.x, 0))
	for i in range(center_index):
		var street_2_filler_inst = street_2_scene.instantiate()
		street_2_filler_inst.rotation_degrees = 90
		streets_insts.append(street_2_filler_inst)
		streets_insts.back().position = TilesInterface.tileCoords_to_trueCoords(Vector2i(starting_x_coord + street_asset_size.x*i, center_index*street_asset_size.y ) + offset_to_current_position_region) + position_correction
		add_child(streets_insts.back())

func set_correct_street_asset(region_coords: Vector2i, offset_to_current_position_region: Vector2i):
	var top_street = false
	var bottom_street = false
	var left_street = false
	var right_street = false
	# Due to the rotation, the position needs to be corrected
	var position_correction = Vector2i(0, 0)

	var x = region_coords.x
	var y = region_coords.y
	if region_matrix[max(y-1, 0)][x] == -2:
		top_street = true
		add_vertically_streets_from_center_to_local_border(0, offset_to_current_position_region)
	if region_matrix[y+1][x] == -2:
		bottom_street = true
		var starting_y = ((TilesInterface.STREET_ASSET_LOCAL_SIZE_FACTOR / 2)+1) * TilesInterface.STREET_ASSET_SIZE_TILE.y
		add_vertically_streets_from_center_to_local_border(starting_y, offset_to_current_position_region)
	if region_matrix[y][max(x-1, 0)] == -2:
		left_street = true
		add_horizontally_streets_from_center_to_local_border(0, offset_to_current_position_region)
	if region_matrix[y][x+1] == -2:
		right_street = true
		var starting_x = ((TilesInterface.STREET_ASSET_LOCAL_SIZE_FACTOR / 2)+1) * TilesInterface.STREET_ASSET_SIZE_TILE.x
		add_horizontally_streets_from_center_to_local_border(starting_x, offset_to_current_position_region)


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
		print("What")
	
	var street_position = (TilesInterface.LOCAL_SIZE_TILES-street_asset_size.x)/2
	streets_insts.back().position = TilesInterface.tileCoords_to_trueCoords(Vector2i(street_position, street_position) + offset_to_current_position_region) + position_correction
	add_child(streets_insts.back())
	
func load_locals():
	for y in range(9):
		if TilesInterface.current_location_region.y+y-4 < 0:
			continue
		elif TilesInterface.current_location_region.y+y-4 >= TilesInterface.REGION_SIZE_TILES:
			break
		for x in range(9):
			if TilesInterface.current_location_region.x+x-4 < 0:
				continue
			elif TilesInterface.current_location_region.x+x-4 >= TilesInterface.REGION_SIZE_TILES:
				break
			generate_local(Vector2i(TilesInterface.current_location_region.x+x-4, TilesInterface.current_location_region.y+y-4))
	TilesInterface.current_location_local = Vector2i(TilesInterface.LOCAL_SIZE_TILES, TilesInterface.LOCAL_SIZE_TILES)/2

func load_from_file(continent_coords: Vector2i, region_coords: Vector2i):
	print("Load specific chunk")
