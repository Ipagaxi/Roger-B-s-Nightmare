extends Node

var current_scene = null

const LOCAL_LOAD_RADIUS = 2
const LOCAL_UNLOAD_RADIUS = 3

const REGION_LOAD_RADIUS = 2
const REGION_UNLOAD_RADIUS = 2

const NUMBER_CIRCULAR_CENTERS = 6
const LOWER_BOUNDARY_CENTER_IDS = 3

func _ready():
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
