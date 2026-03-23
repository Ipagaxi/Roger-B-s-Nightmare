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
	
var rng := RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	atlas_regions.shuffle()
	var tex = $Sprite2D.texture.duplicate()
	$Sprite2D.texture = tex
	$Sprite2D.texture.region = atlas_regions[0]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Global.game_state == Global.GameState.LOCAL:
		
