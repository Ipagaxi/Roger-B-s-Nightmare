extends Node2D

const tileset_file_name = Global.TILESET_FILE_NAME
@onready var tileset = preload("res://assets/Tilesets/" + tileset_file_name)

var region_size = TilesInterface.REGION_SIZE_TILES
# We use 3 here because for city generation the grassland tiles outside the inner city beginn with 3
var id_grassland = 3

func _ready():
	$TileMapLayer.tile_set = tileset


func generate() -> Array[Array]:
	var region_matrix: Array[Array]
	for y in region_size:
		region_matrix.append([])
		for x in region_size:
			region_matrix[y].append(id_grassland)
	return region_matrix
	
func draw():
	for y in region_size:
		for x in region_size:
			$TileMapLayer.set_cell(Vector2i(x, y), 0, Vector2i(4, 1))
	
