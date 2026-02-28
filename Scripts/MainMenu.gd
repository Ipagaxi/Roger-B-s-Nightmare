extends Control

func _ready():
	print("Start Menu")

func _on_exit_button_button_up():
	get_tree().quit()

func _on_play_button_pressed():
	print("Play Game!")
	Global.goto_scene("res://Scenes/GameRun.tscn")

func _input(event):
	if event is InputEventMouseButton:
		print("Mouse event: ", event.button_index, " pressed: ", event.pressed, " pos: ", event.position, " window focus: ", get_window().has_focus())
