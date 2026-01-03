extends StaticBody2D

var local_world: Node2D

var move_dir : = Vector2.ZERO

func _process(delta):
	if Input.is_action_pressed("right") and !Input.is_action_just_released("right"):
		move_dir = Vector2.RIGHT
	elif Input.is_action_pressed("left") and !Input.is_action_just_released("left"):
		move_dir = Vector2.LEFT
	elif Input.is_action_pressed("up") and !Input.is_action_just_released("up"):
		move_dir = Vector2.UP
	elif Input.is_action_pressed("down") and !Input.is_action_just_released("down"):
		move_dir = Vector2.DOWN

func _physics_process(delta):
	if TilesInterface.current_layer_id == 0:#and move_event.is_action(dir) and !move_event.is_action_released(dir):
		var local_size = TilesInterface.LOCAL_SIZE_TILES
		
		var new_global_pos = TilesInterface.trueCoords_to_tileCoords(TilesInterface.move(move_dir, self))
		move_dir = Vector2.ZERO
		TilesInterface.current_location_region = TilesInterface.get_location_region(new_global_pos);
		TilesInterface.current_location_local = Vector2i(posmod(new_global_pos.x, local_size), posmod(new_global_pos.y, local_size))			
		
		local_world.load_all_near_locals()
		local_world.unload_all_far_away_locals()
			
func _input(event):
	pass
