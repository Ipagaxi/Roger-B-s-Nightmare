extends Node2D

var region_size = TilesInterface.REGION_SIZE_TILES
# We use 3 here because for city generation the grassland tiles outside the inner city beginn with 3
var id_grassland = 3

func _ready():
	pass


func generate_outland() -> Array[Array]:
	var region_matrix: Array[Array]
	for y in region_size:
		region_matrix.append([])
		for x in region_size:
			region_matrix[y].append(id_grassland)
			$TileMapLayer.set_cell(Vector2i(x, y), 0, Vector2i(4, 1))
	return region_matrix
