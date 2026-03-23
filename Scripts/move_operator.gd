extends Node2D

@onready var ray: ShapeCast2D = $ShapeCast2D

var moving = false
var move_start_pos: Vector2
var move_end_pos: Vector2

var speed = 1
var body_to_move

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if body_to_move:
		move(move_start_pos, move_end_pos, speed*delta)


func move(start: Vector2, end: Vector2, delta: float) -> bool:
	if not moving:
		return true
	
	var move_dir = (end - start).normalized()
				
	ray.position = end-start + Vector2(0.5 * TilesInterface.TILE_SIZE, 0.5 * TilesInterface.TILE_SIZE)
	ray.target_position = (end-start) * 0.45
	ray.force_shapecast_update()
	if ray.is_colliding():
		moving = false
		return true
	
	return TilesInterface.move(start, end, delta, body_to_move)

# Returns if new movement is triggered
func trigger_movement(end_position: Vector2, body) -> bool:
	var currently_moving = moving
	if not moving:
		body_to_move = body
		moving = true
		move_start_pos = self.global_position
		move_end_pos = end_position
	
	return !currently_moving
