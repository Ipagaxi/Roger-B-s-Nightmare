extends Node2D

@onready var player_scene = preload("res://Scenes/Player.tscn")
@onready var city_scene = preload("res://Scenes/City.tscn")
@onready var chunk_scene = preload("res://Scenes/Chunk.tscn")

var current_layer_id = 0

func _ready():
	await get_tree().process_frame
	var current_chunk = chunk_scene.instantiate()
	current_chunk.load_chunks()
	var player = player_scene.instantiate()
	player.get_node("RemoteTransform2D").remote_path = $"Camera2D".get_path()
	player.global_position = GlobalTileBase.tilePos_to_globalCoords(GlobalTileBase.current_map_location)
	add_child(player)
	$Camera2D.zoom = Vector2(0.5, 0.5)

func _input(event):
	if event.is_action_pressed("zoom_out"):
		if $Camera2D.zoom.x >= 0.25:
			$Camera2D.zoom *= 0.5
	elif event.is_action_pressed("zoom_in"):
		if $Camera2D.zoom.x <= 1.0:
			$Camera2D.zoom *= 2.0
	elif event.is_action_pressed("move_layer_down"):
		change_to_layer(current_layer_id-1)
	elif event.is_action_pressed("move_layer_up"):
		change_to_layer(current_layer_id+1)

func change_to_layer(layer_id: int):
	var valid_layer_id = clamp(layer_id, 0, 2)
	if valid_layer_id != current_layer_id:
		if current_layer_id == 0:
			$Chunk.free()
		elif current_layer_id == 1:
			$City.free()
		elif current_layer_id == 2:
			$Continent.free()
		
		if valid_layer_id == 0:
			$Chunk.instantiate()
			add_child($Chunk)
		elif valid_layer_id == 1:
			$City.instantiate()
			add_child($City)
		elif valid_layer_id == 2:
			$Continent.instantiate()
			add_child($Continent)
