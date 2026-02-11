extends StaticBody2D

var local_handler: Node2D

var region_handler: Node2D


func _input(event):
	for dir in TilesInterface.INPUTS.keys():
		if event.is_action(dir) and !event.is_action_released(dir) and TilesInterface.current_layer_id == 0:
			
			var new_global_pos = TilesInterface.trueCoords_to_tileCoords(TilesInterface.move(dir, self))
			
			TilesInterface.update_layer_positions(new_global_pos)
			
			local_handler.load_all_near_locals(TilesInterface.current_location_continent)
			local_handler.unload_all_far_away_locals()
			
			region_handler.load_all_near_regions()
			region_handler.unload_all_far_away_regions()
