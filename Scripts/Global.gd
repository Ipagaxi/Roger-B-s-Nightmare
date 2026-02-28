extends Node

enum Layer {LOCAL_LAYER, REGION_LAYER, CONTINENT_LAYER}

var current_scene = null

const LOCAL_LOAD_RADIUS = 2
const LOCAL_UNLOAD_RADIUS = 3

const REGION_LOAD_RADIUS = 2
const REGION_UNLOAD_RADIUS = 3

const NUMBER_CIRCULAR_CENTERS = 6
const LOWER_BOUNDARY_CENTER_IDS = 3

const TILESET_FILE_NAME = "tileset_gen6.tres"

var current_layer = Layer.LOCAL_LAYER

var new_scene_path

func _ready():
	var target_screen = 0  # 0 = primary monitor, 1 = second monitor, etc.
	DisplayServer.window_set_current_screen(target_screen)

func goto_scene(path):
	new_scene_path = path
	ResourceLoader.load_threaded_request(path)
	get_tree().change_scene_to_file("res://Scenes/Loading.tscn")
	
func _input(event):
	if event is InputEventMouseButton:
		print("Mouse event: ", event.button_index, " pressed: ", event.pressed, " pos: ", event.position)
		print("Input handled: ", event.is_action_pressed("ui_accept"))
	
