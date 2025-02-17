extends Control


func _on_exit_button_button_up():
	get_tree().quit()


func _on_play_button_button_up():
	Global.goto_scene("res://Scenes/GameRun.tscn")
