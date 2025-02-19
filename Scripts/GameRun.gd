extends Node2D

@onready var city_generator = $CityGenerator
@onready var player_scene = preload("res://Scenes/Player.tscn")

func _ready():
	await get_tree().process_frame
	var player = player_scene.instantiate()
	player.get_node("RemoteTransform2D").remote_path = $"Camera2D".get_path()
	player.global_position = GlobalTileBase.tilePos_to_globalCoords(GlobalTileBase.map_spawn_location)
	add_child(player)
	$Camera2D.zoom = Vector2(0.5, 0.5)

func _input(event):
	if event.is_action_pressed("zoom_out"):
		if $Camera2D.zoom.x >= 0.25:
			$Camera2D.zoom *= 0.5
	elif event.is_action_pressed("zoom_in"):
		if $Camera2D.zoom.x <= 1.0:
			$Camera2D.zoom *= 2.0
