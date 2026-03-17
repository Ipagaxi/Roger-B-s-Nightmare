extends Node2D

const tileset_file_name = Global.TILESET_FILE_NAME
@onready var tileset = preload("res://assets/Tilesets/" + tileset_file_name)

var region_size = TilesInterface.REGION_SIZE_TILES
# We use 3 here because for city generation the grassland tiles outside the inner city beginn with 3
var id_grassland = 3

func _ready():
	pass

func generate() -> Array[Array]:
	var region_matrix: Array[Array]
	for y in region_size:
		region_matrix.append([])
		for x in region_size:
			region_matrix[y].append(id_grassland)
	return region_matrix
	
func draw():
	$TileMapLayer.tile_set = tileset
	var rng := RandomNumberGenerator.new()
	var atlas_coords = [Vector2i(0, 5), Vector2i(1, 5), Vector2i(2, 5), Vector2i(0, 6), Vector2i(1, 6), Vector2i(2, 6), Vector2i(0, 7), Vector2i(1, 7), Vector2i(2, 7)]
	var probabilities = [1, 1, 1, 1, 0.1, 1, 1, 1, 1];
	for y in region_size:
		for x in region_size:
			var variant = atlas_coords[rng.rand_weighted(probabilities)]
			$TileMapLayer.set_cell(Vector2i(x, y), Global.TILESET_USED_ID, variant)
		await get_tree().process_frame
	
