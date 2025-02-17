extends Node2D

func _ready():
	$Camera2D.zoom = Vector2(0.5, 0.5)
	$Player.position = GlobalTileBase.tilePos_to_globalCoords(Vector2(GlobalTileBase.CHUNK_SIZE /2, GlobalTileBase.CHUNK_SIZE/2))

func _input(event):
	if event.is_action_pressed("zoom_out"):
		if $Camera2D.zoom.x >= 0.25:
			$Camera2D.zoom *= 0.5
	elif event.is_action_pressed("zoom_in"):
		if $Camera2D.zoom.x <= 1.0:
			$Camera2D.zoom *= 2.0
