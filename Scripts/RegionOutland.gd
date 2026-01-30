extends Node2D

var region_size = TilesInterface.REGION_SIZE_TILES
# Called when the node enters the scene tree for the first time.
func _ready():
	generate_outland() # Replace with function body.


func generate_outland():
	#var global_tile_coords = TilesInterface.get_global_tile_coords_of_local(region_coords)
	for y in region_size:
		for x in region_size:
			$TileMapLayer.set_cell(Vector2i(x, y), 0, Vector2i(4, 1))
