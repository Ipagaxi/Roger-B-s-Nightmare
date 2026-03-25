extends Control

var duration_sec: float
var passed_duration_sec: float = 0
var fading_out_duration_sec: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	passed_duration_sec += delta
	if passed_duration_sec >= duration_sec:
		queue_free()

func init(p_text: String, p_duration: int, p_fading_out_duration: int):
	duration_sec = p_duration
	fading_out_duration_sec = p_fading_out_duration
	$TextureRect/Label.text = p_text
