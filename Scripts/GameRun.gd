extends Node2D

@onready var player_scene = preload("res://Scenes/Player.tscn")
@onready var continent_scene = preload("res://Scenes/Continent.tscn")
@onready var region_scene = preload("res://Scenes/RegionHandler.tscn")
@onready var local_scene = preload("res://Scenes/LocalHandler.tscn")
@onready var cursor_scene = preload("res://Scenes/Cursor.tscn")
@onready var loading_scene = preload("res://Scenes/Loading.tscn")

signal generation_finished

var player_inst
var continent_inst
var region_inst
var local_inst
var cursor_inst
var loading_inst

var thread = Thread.new()

func _ready():
	#thread.start(_generate_world_threaded)
	generate_run()
	
func _generate_world_threaded():
	pass

func generate_run():
	
	
	# I dont know why the following
	#await get_tree().process_frame
	
	# Generate continent
	print("Generate continent...")
	continent_inst = continent_scene.instantiate()
	continent_inst.visible = false
	continent_inst.generate_continent()
	
	# Generate region
	print("Generate regions...")
	region_inst = region_scene.instantiate()
	region_inst.visible = false
	region_inst.generate_all_near_regions()
	continent_inst.set_city_connecting_roads()
	
	# Generate local
	print("Generate locals...")
	local_inst = local_scene.instantiate()
	local_inst.generate_all_near_locals(TilesInterface.current_location_continent)
	
	print("Instantiate player...")
	player_inst = player_scene.instantiate()
	player_inst.global_position = TilesInterface.tileCoords_to_trueCoords(TilesInterface.current_location_local + TilesInterface.get_global_tile_coords_of_local(TilesInterface.current_location_region, TilesInterface.current_location_continent))
	print("Generation finished!")
	emit_signal("generation_finished")
	
func draw_run():
	set_window_button_according_to_mode()
	add_child(continent_inst)
	region_inst.draw_all_near_regions()
	add_child(region_inst)
	local_inst.draw_all_near_locals()
	add_child(local_inst)
	player_inst.get_node("RemoteTransform2D").remote_path = $Camera2D.get_path()
	add_child(player_inst)
	player_inst.local_handler = local_inst
	player_inst.region_handler = region_inst
	$Camera2D.zoom = Vector2(1, 1)

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


func _on_minimize_button_button_up() -> void:
	# minimize window
	get_window().mode = 1


func _on_window_button_button_up() -> void:
	var current_window_mode = get_window().mode
	var atlas_tex_normal = $CanvasLayer/Control/WindowButton.texture_normal as AtlasTexture
	var atlas_tex_hovered = $CanvasLayer/Control/WindowButton.texture_hover as AtlasTexture
	var atlas_tex_pressed = $CanvasLayer/Control/WindowButton.texture_pressed as AtlasTexture
	if current_window_mode >= 3:
		# change from fullscreen to windowed modus
		get_window().mode = 0
		atlas_tex_normal.region = Rect2(36, 58, 12, 12)
		atlas_tex_hovered.region = Rect2(50, 58, 12, 12)
		atlas_tex_pressed.region = Rect2(64, 58, 12, 12)
	elif current_window_mode <= 2:
		get_window().mode = 3
		atlas_tex_normal.region = Rect2(36, 2, 12, 12)
		atlas_tex_hovered.region = Rect2(50, 2, 12, 12)
		atlas_tex_pressed.region = Rect2(64, 2, 12, 12)

func set_window_button_according_to_mode():
	var current_window_mode = get_window().mode
	var atlas_tex_normal = $CanvasLayer/Control/WindowButton.texture_normal as AtlasTexture
	var atlas_tex_hovered = $CanvasLayer/Control/WindowButton.texture_hover as AtlasTexture
	var atlas_tex_pressed = $CanvasLayer/Control/WindowButton.texture_pressed as AtlasTexture
	if current_window_mode <= 2:
		# use fullscreen icon when windowed
		atlas_tex_normal.region = Rect2(36, 58, 12, 12)
		atlas_tex_hovered.region = Rect2(50, 58, 12, 12)
		atlas_tex_pressed.region = Rect2(64, 58, 12, 12)
	else:
		# use windowed icon when fullscreen
		atlas_tex_normal.region = Rect2(36, 2, 12, 12)
		atlas_tex_hovered.region = Rect2(50, 2, 12, 12)
		atlas_tex_pressed.region = Rect2(64, 2, 12, 12)
