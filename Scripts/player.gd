extends StaticBody2D

var local_handler: Node2D
var region_handler: Node2D

#@onready var collision_rays = $BodyCollisionDetector.get_children()

@onready var ray: ShapeCast2D = $ShapeCast2D

var moving = false
var move_start_pos: Vector2
var move_end_pos: Vector2

var player_speed = 1


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	
	player_move(move_start_pos, move_end_pos, delta*player_speed, self)
	
func player_move(start: Vector2, end: Vector2, delta: float, body) -> bool:
	if not body.moving:
		return true
	
	var move_dir = (end - start).normalized()
				
	ray.position = end-start + Vector2(0.5 * TilesInterface.TILE_SIZE, 0.5 * TilesInterface.TILE_SIZE)
	ray.target_position = (end-start) * 0.45
	ray.force_shapecast_update()
	if ray.is_colliding():
		body.moving = false
		return true
	
	return TilesInterface.move(start, end, delta, body)
	#var cell_data = current_chunk.get_node("house").get_node("Foreground").get_cell_tile_data(globalPos_to_tileCoords(new_pos))
	#if !cell_data:
	#	body.position = new_pos
	#else:
	#	if cell_data.get_meta("Passable"):
	#		body.position = new_pos

func trigger_movement(end_position: Vector2):
	if not moving:
		moving = true
		move_start_pos = self.global_position
		move_end_pos = end_position
		TilesInterface.update_layer_positions(TilesInterface.trueCoords_to_tileCoords(self.global_position))
		
		local_handler.generate_all_near_locals(TilesInterface.current_location_continent)
		local_handler.draw_all_near_locals()
		local_handler.unload_all_far_away_locals()
		
		region_handler.generate_all_near_regions()
		region_handler.draw_all_near_regions()
		region_handler.unload_all_far_away_regions()
