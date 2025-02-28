extends Node2D

@onready var player_scene = preload("res://Scenes/Player.tscn")
@onready var continent_scene = preload("res://Scenes/Continent.tscn")
@onready var city_scene = preload("res://Scenes/City.tscn")
@onready var chunk_scene = preload("res://Scenes/Chunk.tscn")

var player_inst
var continent_inst
var city_inst
var chunk_inst

func _ready():
	await get_tree().process_frame
	# Generate continent
	continent_inst = continent_scene.instantiate()
	continent_inst.visible = false
	add_child(continent_inst)
	# Generate map/city
	city_inst = city_scene.instantiate()
	city_inst.visible = false
	add_child(city_inst)
	# Generate chunk
	chunk_inst = chunk_scene.instantiate()
	chunk_inst.load_chunks()
	add_child(chunk_inst)
	player_inst = player_scene.instantiate()
	player_inst.get_node("RemoteTransform2D").remote_path = $Camera2D.get_path()
	player_inst.global_position = GlobalTileBase.tileCoords_to_globalPos(Vector2i.ZERO)
	add_child(player_inst)
	$Camera2D.zoom = Vector2(0.5, 0.5)
	
func _physics_process(_delta):
	pass

func _input(event):
	if event.is_action_pressed("zoom_out"):
		if $Camera2D.zoom.x >= 0.25:
			$Camera2D.zoom *= 0.5
	elif event.is_action_pressed("zoom_in"):
		if $Camera2D.zoom.x <= 1.0:
			$Camera2D.zoom *= 2.0
	elif event.is_action_pressed("move_layer_down"):
		change_to_layer(GlobalTileBase.current_layer_id-1)
	elif event.is_action_pressed("move_layer_up"):
		change_to_layer(GlobalTileBase.current_layer_id+1)

func change_to_layer(layer_id: int):
	var valid_layer_id = clamp(layer_id, 0, 2)
	if valid_layer_id != GlobalTileBase.current_layer_id:
		if GlobalTileBase.current_layer_id == 0:
			if chunk_inst:
				chunk_inst.visible = false
				#chunk_inst.free()
		elif GlobalTileBase.current_layer_id == 1:
			if city_inst:
				#city_inst.free()
				city_inst.visible = false
		elif GlobalTileBase.current_layer_id == 2:
			if continent_inst:
				continent_inst.visible = false
				#continent_inst.free()
		
		if valid_layer_id == 0:
			#chunk_inst = chunk_scene.instantiate()
			#add_child(chunk_inst)
			player_inst.position = GlobalTileBase.tileCoords_to_globalPos(GlobalTileBase.current_location_chunk)
			chunk_inst.visible = true
		elif valid_layer_id == 1:
			#city_inst = city_scene.instantiate()
			#add_child(city_inst)
			player_inst.position = GlobalTileBase.tileCoords_to_globalPos(GlobalTileBase.current_location_map)
			city_inst.visible = true
		elif valid_layer_id == 2:
			#continent_inst = continent_scene.instantiate()
			#add_child(continent_inst)
			player_inst.position = GlobalTileBase.tileCoords_to_globalPos(GlobalTileBase.current_location_continent)
			continent_inst.visible = true
	GlobalTileBase.current_layer_id = valid_layer_id
