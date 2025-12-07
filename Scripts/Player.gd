extends Area2D

func _input(event):
	for dir in TilesInterface.INPUTS.keys():
		if event.is_action(dir) and !event.is_action_released(dir):# and GlobalTileBase.current_layer_id == 0:
			TilesInterface.move(dir, self)
