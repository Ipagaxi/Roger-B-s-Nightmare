extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer/AspectRatioContainer/LoadingIcon.play("default")


func _process(delta):
	var status = ResourceLoader.load_threaded_get_status(Global.new_scene_path)
	
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			var progress = []
			ResourceLoader.load_threaded_get_status(Global.new_scene_path, progress)
			$CanvasLayer/AspectRatioContainer/ProgressBar.value = progress[0] * 100
		
		ResourceLoader.THREAD_LOAD_LOADED:
			var packed_scene = ResourceLoader.load_threaded_get(Global.new_scene_path)
			var game_instance = packed_scene.instantiate()
			
			game_instance.connect("generation_finished", Callable(self, "_on_generation_done"))
			game_instance.start_world_generation()
			
			get_tree().root.add_child(game_instance)
			get_tree().current_scene = game_instance
			
			set_process(false) # stop checking loader
		
		ResourceLoader.THREAD_LOAD_FAILED:
			print("Failed to load scene.")

func _on_generation_done():
	get_tree().current_scene = get_tree().root.get_child(-1)
	get_tree().current_scene.thread.wait_to_finish()
	get_tree().current_scene.draw_run()
	queue_free() # remove loading scene
