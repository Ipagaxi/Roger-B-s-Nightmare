extends Node

signal message_box_triggered(text, duration, fadding_out_duration)
signal spawn_npc_triggered(global_pos)

func _ready() -> void:
	pass

func show_message_box(text: String, duration, fadding_out_duration):
	message_box_triggered.emit(text, duration, fadding_out_duration)
	
func generate_npc(npc_global_position: Vector2i):
	call_deferred("emit_signal", "spawn_npc_triggered", npc_global_position)
