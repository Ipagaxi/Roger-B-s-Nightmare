extends Node2D

@onready var player_scene = preload("res://Scenes/Player.tscn")
@onready var continent_scene = preload("res://Scenes/Continent.tscn")
@onready var region_scene = preload("res://Scenes/RegionHandler.tscn")
@onready var local_scene = preload("res://Scenes/LocalHandler.tscn")

var player_inst
var continent_inst
var region_inst
var local_inst

func _ready():
	await get_tree().process_frame
	# Generate continent
	continent_inst = continent_scene.instantiate()
	continent_inst.visible = false
	add_child(continent_inst)
	# Generate map/city
	region_inst = region_scene.instantiate()
	region_inst.visible = false
	add_child(region_inst)
	continent_inst.set_city_connecting_roads()
	# Generate chunk
	local_inst = local_scene.instantiate()
	add_child(local_inst)
	player_inst = player_scene.instantiate()
	player_inst.get_node("RemoteTransform2D").remote_path = $Camera2D.get_path()
	player_inst.global_position = TilesInterface.tileCoords_to_trueCoords(TilesInterface.current_location_local + TilesInterface.get_global_tile_coords_of_local(TilesInterface.current_location_region))
	print("Player starting position: ", player_inst.global_position)
	add_child(player_inst)
	player_inst.local_world = local_inst
	$Camera2D.zoom = Vector2(0.5, 0.5)
	
func _physics_process(_delta):
	pass

func _input(event):
	if event.is_action_pressed("zoom_out"):
		if $Camera2D.zoom.x >= 0.125:
			$Camera2D.zoom *= 0.5
	elif event.is_action_pressed("zoom_in"):
		if $Camera2D.zoom.x <= 1.0:
			$Camera2D.zoom *= 2.0
	elif event.is_action_pressed("move_layer_down"):
		change_to_layer(TilesInterface.current_layer_id-1)
	elif event.is_action_pressed("move_layer_up"):
		change_to_layer(TilesInterface.current_layer_id+1)

func change_to_layer(layer_id: int):
	var valid_layer_id = clamp(layer_id, 0, 2)
	if valid_layer_id != TilesInterface.current_layer_id:
		if TilesInterface.current_layer_id == 0:
			if local_inst:
				local_inst.visible = false
				#chunk_inst.free()
		elif TilesInterface.current_layer_id == 1:
			if region_inst:
				#city_inst.free()
				region_inst.visible = false
		elif TilesInterface.current_layer_id == 2:
			if continent_inst:
				continent_inst.visible = false
				#continent_inst.free()
		
		if valid_layer_id == 0:
			#chunk_inst = chunk_scene.instantiate()
			#add_child(chunk_inst)
			player_inst.position = TilesInterface.tileCoords_to_trueCoords(TilesInterface.get_global_tile_coords_of_local(TilesInterface.current_location_region)+ TilesInterface.current_location_local)
			local_inst.visible = true
		elif valid_layer_id == 1:
			#city_inst = city_scene.instantiate()
			#add_child(city_inst)
			player_inst.position = TilesInterface.tileCoords_to_trueCoords(TilesInterface.current_location_region)
			region_inst.visible = true
		elif valid_layer_id == 2:
			#continent_inst = continent_scene.instantiate()
			#add_child(continent_inst)
			player_inst.position = TilesInterface.tileCoords_to_trueCoords(TilesInterface.current_location_continent)
			continent_inst.visible = true
	TilesInterface.current_layer_id = valid_layer_id
