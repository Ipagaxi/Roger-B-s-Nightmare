extends Node2D

var atlas_regions: Array[Rect2] = [
	Rect2(64.0, 0.0, 32.0, 48.0),
	Rect2(96.0, 0.0, 32.0, 48.0),
	Rect2(0.0, 48.0, 32.0, 48.0),
	Rect2(32.0, 48.0, 32.0, 48.0),
	Rect2(64.0, 48.0, 32.0, 48.0),
	Rect2(96.0, 48.0, 32.0, 48.0),
	Rect2(0.0, 96.0, 32.0, 48.0),
	Rect2(32.0, 96.0, 32.0, 48.0),
	Rect2(64.0, 96.0, 32.0, 48.0),
	Rect2(96.0, 96.0, 32.0, 48.0)
]
	
var move_dir: Array[Vector2] = [
	Vector2(0, 0),
	Vector2(0, 1),
	Vector2(1, 0),
	Vector2(1, 1),
	Vector2(0, -1),
	Vector2(-1, 0),
	Vector2(-1, -1)
]

var move_weights: Array = [600, 1, 1, 1, 1, 1, 1]
	
var rng := RandomNumberGenerator.new()

@export var data_inventory = DataInventory.new(15)

# Called when the node enters the scene tree for the first time.
func _ready():
	atlas_regions.shuffle()
	var tex = $Sprite2D.texture.duplicate()
	$Sprite2D.texture = tex
	$Sprite2D.texture.region = atlas_regions[0]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Global.get_game_state() == Global.GameState.LOCAL:
		var move_dir = move_dir[rng.rand_weighted(move_weights)] * TilesInterface.TILE_SIZE
		if move_dir != Vector2(0, 0):
			$MoveOperator.trigger_movement(self.global_position+move_dir, self)
