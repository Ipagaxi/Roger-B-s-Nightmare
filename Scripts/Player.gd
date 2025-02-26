extends Area2D

func _input(event):
	for dir in GlobalTileBase.INPUTS.keys():
		if event.is_action(dir) and !event.is_action_released(dir):
			GlobalTileBase.move(dir, self)
