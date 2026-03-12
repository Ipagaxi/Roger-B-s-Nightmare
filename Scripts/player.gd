extends StaticBody2D

var local_handler: Node2D

var region_handler: Node2D

var moving = false


func _input(event):
	if moving:
		return
	for dir in TilesInterface.INPUTS.keys():
		if event.is_action(dir) and !event.is_action_released(dir) and Global.current_layer == Global.Layer.LOCAL_LAYER:
			var new_global_pos = TilesInterface.trueCoords_to_tileCoords(await TilesInterface.player_move(dir, self))
			if not moving:
				TilesInterface.update_layer_positions(new_global_pos)
				
				local_handler.generate_all_near_locals(TilesInterface.current_location_continent)
				local_handler.draw_all_near_locals()
				local_handler.unload_all_far_away_locals()
				
				region_handler.generate_all_near_regions()
				region_handler.draw_all_near_regions()
				region_handler.unload_all_far_away_regions()
