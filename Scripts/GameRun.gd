extends Node2D

@onready var player_scene = preload("res://Scenes/Player.tscn")
@onready var continent_scene = preload("res://Scenes/Continent.tscn")
@onready var region_scene = preload("res://Scenes/RegionHandler.tscn")
@onready var local_scene = preload("res://Scenes/LocalHandler.tscn")
@onready var cursor_scene = preload("res://Scenes/Cursor.tscn")

var player_inst
var continent_inst
var region_inst
var local_inst
var cursor_inst

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
	local_inst.load_all_near_locals(TilesInterface.current_location_continent)
	add_child(local_inst)
	player_inst = player_scene.instantiate()
	player_inst.get_node("RemoteTransform2D").remote_path = $Camera2D.get_path()
	player_inst.global_position = TilesInterface.tileCoords_to_trueCoords(TilesInterface.current_location_local + TilesInterface.get_global_tile_coords_of_local(TilesInterface.current_location_region, TilesInterface.current_location_continent))
	print("Player starting position: ", player_inst.global_position)
	add_child(player_inst)
	player_inst.local_handler = local_inst
	player_inst.region_handler = region_inst
	$Camera2D.zoom = Vector2(1, 1)
	
func _physics_process(_delta):
	pass

func _input(event):
	if event.is_action_pressed("zoom_out"):
		if $Camera2D.zoom.x > 0.5:
			$Camera2D.zoom *= 0.5
	elif event.is_action_pressed("zoom_in"):
		if $Camera2D.zoom.x <= 1.0:
			$Camera2D.zoom *= 2.0
	elif event.is_action_pressed("open_continent_layer"):
		local_inst.visible = false
		region_inst.visible = false
		player_inst.position = TilesInterface.tileCoords_to_trueCoords(TilesInterface.current_location_continent)
		Global.current_layer = Global.Layer.CONTINENT_LAYER
		continent_inst.visible = true
	elif event.is_action_pressed("open_region_layer"):
		local_inst.visible = false
		continent_inst.visible = false
		player_inst.position = TilesInterface.tileCoords_to_trueCoords(TilesInterface.current_location_region + TilesInterface.current_location_continent*TilesInterface.REGION_SIZE_TILES)
		Global.current_layer = Global.Layer.REGION_LAYER
		region_inst.visible = true
	elif event.is_action_pressed("open_local_layer"):
		region_inst.visible = false
		continent_inst.visible = false
		player_inst.position = TilesInterface.tileCoords_to_trueCoords(TilesInterface.get_global_tile_coords_of_local(TilesInterface.current_location_region, TilesInterface.current_location_continent)+ TilesInterface.current_location_local)
		Global.current_layer = Global.Layer.LOCAL_LAYER
		local_inst.visible = true
	elif event.is_action_pressed("use_cursor"):
		if cursor_inst:
			player_inst.get_node("RemoteTransform2D").remote_path = $Camera2D.get_path()
			cursor_inst.get_node("RemoteTransform2D").remote_path = NodePath("")
			cursor_inst.queue_free()
			player_inst.set_process_input(true)
		else:
			player_inst.set_process_input(false)
			cursor_inst = cursor_scene.instantiate()
			cursor_inst.position = player_inst.position
			add_child(cursor_inst)
			cursor_inst.get_node("RemoteTransform2D").remote_path = $Camera2D.get_path()
			player_inst.get_node("RemoteTransform2D").remote_path = NodePath("")

func _on_exit_button_button_up() -> void:
	get_tree().quit()
