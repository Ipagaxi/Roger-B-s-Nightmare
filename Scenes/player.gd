extends Area2D

func _input(event):
	for dir in GlobalTileBase.INPUTS.keys():
		if event.is_action(dir):
			position += GlobalTileBase.move(dir)
