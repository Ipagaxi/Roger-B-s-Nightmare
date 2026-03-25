extends Node2D

signal zoom_out_triggered
signal zoom_in_triggered
signal open_continent_layer_triggered
signal open_region_layer_triggered
signal open_local_layer_triggered
signal toggle_cursor_triggered
signal toggle_character_menu_triggered
signal pickpocket_victim_triggered

var input_actions := {}

var player_inst: StaticBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# [KEY, SHIFT_PRESSED]
	input_actions = {
		[KEY_Z, false]: z_pressed,
		[KEY_Z, true]: z_shift_pressed,
		[KEY_C, false]: c_pressed,
		[KEY_M, false]: m_pressed,
		[KEY_L, false]: l_pressed,
		[KEY_X, false]: x_pressed,
		[KEY_C, true]: c_shift_pressed,
		[KEY_P, false]: p_pressed,
	}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if Global.game_state == Global.GameState.LOCAL:
		handle_player_movement(event)

	if event is InputEventKey and event.pressed:
		for action in input_actions.keys():
			if event.keycode == action[0] and event.shift_pressed == action[1]:
				input_actions[action].call()
				break

# ---------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------

func handle_player_movement(event):
	if not player_inst.get_node("MoveOperator").moving:
		for dir in TilesInterface.INPUTS.keys():
				if event.is_action(dir) and !event.is_action_released(dir):
					player_inst.trigger_movement(player_inst.global_position + TilesInterface.tileCoords_to_trueCoords(TilesInterface.INPUTS[dir])/1.0)

# ---------------------------------------------------------------
# Input action functions
# ---------------------------------------------------------------

func z_pressed():
	match Global.game_state:
		Global.GameState.LOCAL:
			zoom_in_triggered.emit()
		Global.GameState.REGION:
			zoom_in_triggered.emit()
		Global.GameState.CONTINENT:
			zoom_in_triggered.emit()
	
func z_shift_pressed():
	match Global.game_state:
		Global.GameState.LOCAL:
			zoom_out_triggered.emit()
		Global.GameState.REGION:
			zoom_out_triggered.emit()
		Global.GameState.CONTINENT:
			zoom_out_triggered.emit()
		
func c_pressed():
	match Global.game_state:
		Global.GameState.LOCAL:
			open_continent_layer_triggered.emit()
		Global.GameState.REGION:
			open_continent_layer_triggered.emit()
	
func m_pressed():
	match Global.game_state:
			Global.GameState.LOCAL:
				open_region_layer_triggered.emit()
			Global.GameState.CONTINENT:
				open_region_layer_triggered.emit()

func l_pressed():
	match Global.game_state:
		Global.GameState.REGION:
			open_local_layer_triggered.emit()
		Global.GameState.CONTINENT:
			open_local_layer_triggered.emit()

func x_pressed():
	match Global.game_state:
		Global.GameState.LOCAL:
			toggle_cursor_triggered.emit()
		Global.GameState.REGION:
			toggle_cursor_triggered.emit()
		Global.GameState.CONTINENT:
			toggle_cursor_triggered.emit()
		Global.GameState.CURSOR:
			toggle_cursor_triggered.emit()

func c_shift_pressed():
	match Global.game_state:
		Global.GameState.LOCAL:
			toggle_character_menu_triggered.emit()
		Global.GameState.REGION:
			toggle_character_menu_triggered.emit()
		Global.GameState.CONTINENT:
			toggle_character_menu_triggered.emit()
		Global.GameState.CHARACTER_MENU:
			toggle_character_menu_triggered.emit()
			
func p_pressed():
	match Global.game_state:
		Global.GameState.LOCAL:
			pickpocket_victim_triggered.emit()
