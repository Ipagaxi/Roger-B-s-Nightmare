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
	
	return TilesInterface.slide_move(start, end, delta, body_to_move)

# Returns if new movement is triggered
func trigger_movement(end_position: Vector2, body) -> bool:
	var currently_moving = moving
	if not moving:
		var dir = end_position-body.global_position
		ray.position = dir + Vector2(0.5 * TilesInterface.TILE_SIZE, 0.5 * TilesInterface.TILE_SIZE)
		ray.target_position = dir * 0.45
		ray.force_shapecast_update()
		if ray.is_colliding():
			moving = false
			return false

		body_to_move = body
		moving = true
		move_start_pos = self.global_position
		move_end_pos = end_position
		var body_sprite = body.get_node("Sprite2D")
		var dir_x = (end_position-body.global_position).x
		if dir_x != 0:
			body_sprite.flip_h = dir_x > 0
	
	return !currently_moving
