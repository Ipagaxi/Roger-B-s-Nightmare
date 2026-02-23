extends Node

enum Layer {LOCAL_LAYER, REGION_LAYER, CONTINENT_LAYER}

var current_scene = null

const LOCAL_LOAD_RADIUS = 2
const LOCAL_UNLOAD_RADIUS = 3

const REGION_LOAD_RADIUS = 2
const REGION_UNLOAD_RADIUS = 2

const NUMBER_CIRCULAR_CENTERS = 6
const LOWER_BOUNDARY_CENTER_IDS = 3

const TILESET_FILE_NAME = "tileset_gen6.tres"

var current_layer = Layer.LOCAL_LAYER

func _ready():
	var target_screen = 0  # 0 = primary monitor, 1 = second monitor, etc.
	DisplayServer.window_set_current_screen(target_screen)
	var root = get_tree().root
	current_scene = root.get_child(-1)

func goto_scene(path):
	_deferred_goto_scene.call_deferred(path)
	
func _deferred_goto_scene(path):
	current_scene.free()
	
	var s = ResourceLoader.load(path)
	
	current_scene = s.instantiate()
	
	get_tree().root.add_child(current_scene)
	
	get_tree().current_scene = current_scene
