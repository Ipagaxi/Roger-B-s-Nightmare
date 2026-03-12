extends StaticBody2D

var local_handler: Node2D
var region_handler: Node2D

var moving = false
var move_start_pos: Vector2
var move_end_pos: Vector2

var player_speed = 1

func _process(delta: float) -> void:
	TilesInterface.move(move_start_pos, move_end_pos, delta*player_speed, self)

func trigger_movement(end_position: Vector2):
	print("play should move")
	if not moving:
		moving = true
		print("player will move")
		move_start_pos = self.global_position
		move_end_pos = end_position
		TilesInterface.update_layer_positions(TilesInterface.trueCoords_to_tileCoords(self.global_position))
		
		local_handler.generate_all_near_locals(TilesInterface.current_location_continent)
		local_handler.draw_all_near_locals()
		local_handler.unload_all_far_away_locals()
		
		region_handler.generate_all_near_regions()
		region_handler.draw_all_near_regions()
		region_handler.unload_all_far_away_regions()
