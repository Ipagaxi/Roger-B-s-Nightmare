extends Node

var loading_scene = preload("res://Scenes/Loading.tscn")

enum Layer {LOCAL_LAYER, REGION_LAYER, CONTINENT_LAYER}

enum GameState {LOCAL, REGION, CONTINENT, MAIN_MENU, CHARACTER_MENU, PAUSE_MENU, CURSOR}

signal message_box_triggered(text, duration, fadding_out_duration)

# Change the game state with the provided method
var game_state = GameState.MAIN_MENU
var last_game_state = GameState.MAIN_MENU

var current_scene = null

const LOCAL_LOAD_RADIUS = 2
const LOCAL_UNLOAD_RADIUS = 3

const REGION_LOAD_RADIUS = 2
const REGION_UNLOAD_RADIUS = 3

const NUMBER_CIRCULAR_CENTERS = 6
const LOWER_BOUNDARY_CENTER_IDS = 3

const TILESET_FILE_NAME = "tileset.tres"
const TILESET_USED_ID = 0

var current_layer = Layer.LOCAL_LAYER

var new_scene_path

func _ready():
	var target_screen = 0  # 0 = primary monitor, 1 = second monitor, etc.
	DisplayServer.window_set_current_screen(target_screen)

func goto_scene(path):
	_deferred_goto_scene.call_deferred(path)

func _deferred_goto_scene(path):
	new_scene_path = path
	ResourceLoader.load_threaded_request(path)
	get_tree().change_scene_to_packed(loading_scene)

func change_game_state_to(new_game_state: GameState):
	last_game_state = game_state
	game_state = new_game_state
	
func change_game_state_back():
	var tmp = last_game_state
	last_game_state = game_state
	game_state = tmp

func show_message_box(text: String, duration, fadding_out_duration):
	message_box_triggered.emit(text, duration, fadding_out_duration)
