extends Control


var equip_interface_inst

# Called when the node enters the scene tree for the first time.
func _ready():
	InputController.close_equip_interface.connect(return_from_equip_interface)
	InputController.close_stats_interface.connect(return_from_stats_interface)
	InputController.close_cbm_interface.connect(return_from_cbm_interface)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_stats_button_pressed() -> void:
	$StatsInterface.visible = true
	Global.change_game_state_to(Global.GameState.STATS_INTERFACE)

func _on_equipment_button_pressed():
	$EquipInterface.visible = true
	Global.change_game_state_to(Global.GameState.EQUIP_INTERFACE)

func _on_cbm_button_pressed():
	$CbmInterface.visible = true
	Global.change_game_state_to(Global.GameState.CBM_INTERFACE)

func return_from_stats_interface():
	$StatsInterface.visible = false
	Global.change_game_state_back()

func return_from_equip_interface():
	$EquipInterface.visible = false
	Global.change_game_state_back()

func return_from_cbm_interface():
	print("exit received")
	$CbmInterface.visible = false
	Global.change_game_state_back()
