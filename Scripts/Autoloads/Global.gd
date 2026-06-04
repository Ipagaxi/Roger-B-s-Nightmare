extends Node

var loading_scene = preload("res://Scenes/Loading.tscn")

### The following consts are just for type-safety
const LocalLayer = preload("res://Scripts/LocalLayer/local_handler.gd")
const RegionLayer = preload("res://Scripts/RegionLayer/region_handler.gd")

enum Layer {LOCAL_LAYER, REGION_LAYER, CONTINENT_LAYER}

enum GameState {LOCAL, REGION, CONTINENT, MAIN_MENU, NEURAL_LAYER, CHARACTER_MENU, PAUSE_MENU, CURSOR, STATS_INTERFACE, EQUIP_INTERFACE, CBM_INTERFACE}

var current_scene = null

const LOCAL_LOAD_RADIUS = 2
const LOCAL_UNLOAD_RADIUS = 3

const REGION_LOAD_RADIUS = 2
const REGION_UNLOAD_RADIUS = 3

const NUMBER_CIRCULAR_CENTERS = 6
const LOWER_BOUNDARY_CENTER_IDS = 3

const TILESET_FILE_NAME = "tileset.tres"
const TILESET_USED_ID = 0

var game_state_stack = [ GameState.MAIN_MENU ]

var current_layer = Layer.LOCAL_LAYER

var new_scene_path

var controlled_entity

var local_handler: LocalLayer
var region_handler: RegionLayer

func _ready():
	var target_screen = 0  # 0 = primary monitor, 1 = second monitor, etc.
	DisplayServer.window_set_current_screen(target_screen)

func goto_scene(path):
	_deferred_goto_scene.call_deferred(path)

func _deferred_goto_scene(path):
	new_scene_path = path
	ResourceLoader.load_threaded_request(path)
	get_tree().change_scene_to_packed(loading_scene)

func get_game_state() -> GameState:
	return game_state_stack.back()

func change_game_state_to(new_game_state: GameState):
	if new_game_state != get_game_state():
		game_state_stack.push_back(new_game_state)
	if game_state_stack.size() > 10:
		game_state_stack.pop_front()
	
func change_game_state_back():
	game_state_stack.pop_back()
