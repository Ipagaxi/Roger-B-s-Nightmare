extends StaticBody2D

var local_world: Node2D


func _input(event):
	for dir in TilesInterface.INPUTS.keys():
		if event.is_action(dir) and !event.is_action_released(dir) and TilesInterface.current_layer_id == 0:
			var local_size = TilesInterface.LOCAL_SIZE_TILES
			
			var new_global_pos = TilesInterface.trueCoords_to_tileCoords(TilesInterface.move(dir, self))
			TilesInterface.current_location_region = TilesInterface.get_location_region(new_global_pos);
			TilesInterface.current_location_local = Vector2i(posmod(new_global_pos.x, local_size), posmod(new_global_pos.y, local_size))			
			
			local_world.load_all_near_locals()
			local_world.unload_all_far_away_locals()
