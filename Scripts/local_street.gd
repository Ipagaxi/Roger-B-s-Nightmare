extends Node2D

var street_1_scene = preload("res://Map/Streets/street_1.tmx")
var street_2_scene = preload("res://Map/Streets/street_2.tmx")
var street_2_edge_scene = preload("res://Map/Streets/street_2_edge.tmx")
var street_3_scene = preload("res://Map/Streets/street_3.tmx")
var street_4_scene = preload("res://Map/Streets/street_4.tmx")

var street_asset_size = TilesInterface.STREET_ASSET_SIZE_TILE

var street_inst

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func generate(region_coords: Vector2i, continent_coords: Vector2i):
	set_correct_street_asset(region_coords, continent_coords)
	
func draw():
	add_child(street_inst)
	apply_variation_to_street_tiles()
	
func set_correct_street_asset(region_coords: Vector2i, continent_coords: Vector2i):
	var region_matrix = TilesInterface.continent_region_matrices[continent_coords.y][continent_coords.x]
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
		street_inst = street_1_scene.instantiate()
		street_inst.rotation_degrees = 180
		position_correction = TilesInterface.tileCoords_to_trueCoords(street_asset_size)
	elif !top_street and bottom_street and !left_street and !right_street:
		street_inst = street_1_scene.instantiate()
		position_correction = Vector2i(0, 0)
	elif !top_street and !bottom_street and left_street and !right_street:
		street_inst = street_1_scene.instantiate()
		street_inst.rotation_degrees = 90
		position_correction = TilesInterface.tileCoords_to_trueCoords(Vector2i(street_asset_size.x, 0))
	elif !top_street and !bottom_street and !left_street and right_street:
		street_inst = street_1_scene.instantiate()
		street_inst.rotation_degrees = 270
		position_correction = TilesInterface.tileCoords_to_trueCoords(Vector2i(0, street_asset_size.y))
		
	# Two opposite exits
	elif top_street and bottom_street and !left_street and !right_street:
		street_inst = street_2_scene.instantiate()
		position_correction = Vector2i(0, 0)
	elif !top_street and !bottom_street and left_street and right_street:
		street_inst = street_2_scene.instantiate()
		street_inst.rotation_degrees = 90
		position_correction = TilesInterface.tileCoords_to_trueCoords(Vector2i(street_asset_size.x, 0))
		
	# Two edge exits
	elif top_street and !bottom_street and left_street and !right_street:
		street_inst = street_2_edge_scene.instantiate()
		street_inst.rotation_degrees = 270
		position_correction = TilesInterface.tileCoords_to_trueCoords(Vector2i(0, street_asset_size.y))
	elif top_street and !bottom_street and !left_street and right_street:
		street_inst = street_2_edge_scene.instantiate()
		position_correction = Vector2i(0, 0)
	elif !top_street and bottom_street and left_street and !right_street:
		street_inst = street_2_edge_scene.instantiate()
		street_inst.rotation_degrees = 180
		position_correction = TilesInterface.tileCoords_to_trueCoords(street_asset_size)
	elif !top_street and bottom_street and !left_street and right_street:
		street_inst = street_2_edge_scene.instantiate()
		street_inst.rotation_degrees = 90
		position_correction = TilesInterface.tileCoords_to_trueCoords(Vector2i(street_asset_size.x, 0))
		
	# Three exits
	elif top_street and !bottom_street and left_street and right_street:
		street_inst = street_3_scene.instantiate()
		position_correction = Vector2i(0, 0)
	elif top_street and bottom_street and !left_street and right_street:
		street_inst = street_3_scene.instantiate()
		street_inst.rotation_degrees = 90
		position_correction = TilesInterface.tileCoords_to_trueCoords(Vector2i(street_asset_size.x, 0))
	elif !top_street and bottom_street and left_street and right_street:
		street_inst = street_3_scene.instantiate()
		street_inst.rotation_degrees = 180
		position_correction = TilesInterface.tileCoords_to_trueCoords(street_asset_size)
	elif top_street and bottom_street and left_street and !right_street:
		street_inst = street_3_scene.instantiate()
		street_inst.rotation_degrees = 270
		position_correction = TilesInterface.tileCoords_to_trueCoords(Vector2i(0, street_asset_size.y))
	# Four exits
	elif top_street and bottom_street and left_street and right_street:
		street_inst = street_4_scene.instantiate()
	else:
		print("Problem with placing center street")
	
	street_inst.position += Vector2(position_correction)
	
func apply_variation_to_street_tiles():
	var street_asphalt_tilemap = street_inst.get_child(0)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(street_inst.position)# + variation_seed_offset
	var atlas_coords = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0)]
	var probabilities = [100, 0.5, 0.5, 0.1, 0.1];

	for cell in street_asphalt_tilemap.get_used_cells():

		if street_asphalt_tilemap.get_cell_atlas_coords(cell) == Vector2i.ZERO:
			var variant = atlas_coords[rng.rand_weighted(probabilities)]
			if variant != Vector2i.ZERO:
				street_asphalt_tilemap.set_cell(cell, 1, variant)
