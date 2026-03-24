extends StaticBody2D

@export var data_inventory: Resource

var local_handler: Node2D
var region_handler: Node2D

#@onready var collision_rays = $BodyCollisionDetector.get_children()


func _ready() -> void:
	if data_inventory:
		print(data_inventory.money)

func _process(delta: float) -> void:
	pass
	#$MoveOperator.move(move_start_pos, move_end_pos, delta*player_speed, self)

func trigger_movement(end_position: Vector2):
	if $MoveOperator.trigger_movement(end_position, self):
		TilesInterface.update_layer_positions(TilesInterface.trueCoords_to_tileCoords(self.global_position))
		
		local_handler.generate_all_near_locals(TilesInterface.current_location_continent)
		local_handler.draw_all_near_locals()
		local_handler.unload_all_far_away_locals()
		
		region_handler.generate_all_near_regions()
		region_handler.draw_all_near_regions()
		region_handler.unload_all_far_away_regions()
