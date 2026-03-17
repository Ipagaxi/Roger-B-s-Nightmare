extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	for dir in TilesInterface.INPUTS.keys():
		if event.is_action(dir) and !event.is_action_released(dir):
			TilesInterface.move(dir, self)
