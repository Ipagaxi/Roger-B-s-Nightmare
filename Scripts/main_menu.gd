extends Control

var sin_vec = Vector2(0.1, 0)

func _ready():
	pass
	
func _process(delta: float) -> void:
	sin_vec = sin_vec.rotated(asin(delta*3))
	$UI/TitleSprite.scale = Vector2(4, 4) + Vector2(sin_vec.y, sin_vec.y)

func _on_play_button_pressed():
	Global.goto_scene("res://Scenes/GameRun.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()
