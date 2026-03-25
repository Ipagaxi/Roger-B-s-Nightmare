extends StaticBody2D

# Extensions
var data_inventory = DataInventory.new(5)
var character_actions = CharacterActions.new()

var local_handler: Node2D
var region_handler: Node2D

func _ready() -> void:
	InputController.pickpocket_victim_triggered.connect(pickpocket_target)

func _process(delta: float) -> void:
	pass

func trigger_movement(end_position: Vector2):
	if $MoveOperator.trigger_movement(end_position, self):
		TilesInterface.update_layer_positions(TilesInterface.trueCoords_to_tileCoords(self.global_position))
		
		local_handler.generate_all_near_locals(TilesInterface.current_location_continent)
		local_handler.draw_all_near_locals()
		local_handler.unload_all_far_away_locals()
		
		region_handler.generate_all_near_regions()
		region_handler.draw_all_near_regions()
		region_handler.unload_all_far_away_regions()

func pickpocket_target():
	var collision_ray = $MoveOperator.get_node("ShapeCast2D")
	if collision_ray.is_colliding():
		var target = collision_ray.get_collider(0)
		character_actions.pickpocket(self, target)
	else:
		print("No victim in sight")
