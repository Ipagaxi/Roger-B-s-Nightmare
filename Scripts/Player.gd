extends Area2D

var local_world: Node2D


func _input(event):
	for dir in TilesInterface.INPUTS.keys():
		if event.is_action(dir) and !event.is_action_released(dir):# and GlobalTileBase.current_layer_id == 0:
			var local_pos = TilesInterface.current_location_local
			var local_size = TilesInterface.LOCAL_SIZE_TILES
			var player_was_in_top_local_rim = (local_pos.y % local_size) <= (local_size*0.2)
			var player_was_in_bottom_local_rim = (local_pos.y % local_size) >= (local_size*0.8)
			var player_was_in_left_local_rim = (local_pos.x % local_size) <= (local_size*0.2)
			var player_was_in_right_local_rim = (local_pos.x % local_size) >= (local_size*0.8)
			
			var new_global_pos = TilesInterface.trueCoords_to_tileCoords(TilesInterface.move(dir, self))
			TilesInterface.current_location_region = TilesInterface.get_location_region(new_global_pos);
			TilesInterface.current_location_local = Vector2i(posmod(new_global_pos.x, local_size), posmod(new_global_pos.y, local_size))
			print("player pos: ", TilesInterface.get_global_tile_coords_of_local(TilesInterface.current_location_region) + TilesInterface.current_location_local)
			local_pos = TilesInterface.current_location_local
			var pos_in_local = (local_pos.y % local_size)
			var player_is_in_top_local_rim = (local_pos.y % local_size) <= (local_size*0.2)
			var player_is_in_bottom_local_rim = (local_pos.y % local_size) >= (local_size*0.8)
			var player_is_in_left_local_rim = (local_pos.x % local_size) <= (local_size*0.2)
			var player_is_in_right_local_rim = (local_pos.x % local_size) >= (local_size*0.8)
			
			if !player_was_in_top_local_rim && player_is_in_top_local_rim && !player_was_in_bottom_local_rim:
				# Generate a new row of locals in movement direction, at least a row of three
				var num_additional_locals_to_generate_per_direction = max(Global.NUM_LOCALS_LOADING_IN_EACH_DIRECTION, 1)
				for i in range(2*num_additional_locals_to_generate_per_direction+1):
					local_world.generate_local(Vector2i(TilesInterface.current_location_region.x - num_additional_locals_to_generate_per_direction + i, TilesInterface.current_location_region.y - Global.NUM_LOCALS_LOADING_IN_EACH_DIRECTION - 1))
					local_world.unload_local(Vector2i(TilesInterface.current_location_region.x - num_additional_locals_to_generate_per_direction + i, TilesInterface.current_location_region.y + Global.NUM_LOCALS_LOADING_IN_EACH_DIRECTION + 1))
			if !player_was_in_bottom_local_rim && player_is_in_bottom_local_rim && !player_was_in_top_local_rim:
				var num_additional_locals_to_generate_per_direction = max(Global.NUM_LOCALS_LOADING_IN_EACH_DIRECTION, 1)
				for i in range(2*num_additional_locals_to_generate_per_direction+1):
					local_world.generate_local(Vector2i(TilesInterface.current_location_region.x - num_additional_locals_to_generate_per_direction + i, TilesInterface.current_location_region.y + Global.NUM_LOCALS_LOADING_IN_EACH_DIRECTION + 1))
					local_world.unload_local(Vector2i(TilesInterface.current_location_region.x - num_additional_locals_to_generate_per_direction + i, TilesInterface.current_location_region.y - Global.NUM_LOCALS_LOADING_IN_EACH_DIRECTION - 1))
			if !player_was_in_left_local_rim && player_is_in_left_local_rim && !player_was_in_right_local_rim:
				var num_additional_locals_to_generate_per_direction = max(Global.NUM_LOCALS_LOADING_IN_EACH_DIRECTION, 1)
				for i in range(2*num_additional_locals_to_generate_per_direction+1):
					local_world.generate_local(Vector2i(TilesInterface.current_location_region.x - Global.NUM_LOCALS_LOADING_IN_EACH_DIRECTION - 1, TilesInterface.current_location_region.y - num_additional_locals_to_generate_per_direction + i))
					local_world.unload_local(Vector2i(TilesInterface.current_location_region.x + Global.NUM_LOCALS_LOADING_IN_EACH_DIRECTION + 1, TilesInterface.current_location_region.y - num_additional_locals_to_generate_per_direction + i))
			if !player_was_in_right_local_rim && player_is_in_right_local_rim && !player_was_in_left_local_rim:
				var num_additional_locals_to_generate_per_direction = max(Global.NUM_LOCALS_LOADING_IN_EACH_DIRECTION, 1)
				for i in range(2*num_additional_locals_to_generate_per_direction+1):
					local_world.generate_local(Vector2i(TilesInterface.current_location_region.x + Global.NUM_LOCALS_LOADING_IN_EACH_DIRECTION + 1, TilesInterface.current_location_region.y - num_additional_locals_to_generate_per_direction + i))
					local_world.unload_local(Vector2i(TilesInterface.current_location_region.x - Global.NUM_LOCALS_LOADING_IN_EACH_DIRECTION - 1, TilesInterface.current_location_region.y - num_additional_locals_to_generate_per_direction + i))
					
