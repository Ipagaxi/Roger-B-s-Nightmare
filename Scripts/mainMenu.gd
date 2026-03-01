extends Control

func _ready():
	pass

func _on_play_button_pressed():
	Global.goto_scene("res://Scenes/GameRun.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()
