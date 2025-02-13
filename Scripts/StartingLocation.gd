extends Node2D

func _ready():
	$Player.position = GlobalTileBase.map_position(Vector2(10, 10))
