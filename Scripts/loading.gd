extends Node2D

var scene_loaded := false  # guard flag to prevent double execution

func _ready() -> void:
	$CanvasLayer/AspectRatioContainer/LoadingIcon.play("default")

func _process(delta):
	if scene_loaded:
		return
		
	var status = ResourceLoader.load_threaded_get_status(Global.new_scene_path)
	
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			var progress = []
			ResourceLoader.load_threaded_get_status(Global.new_scene_path, progress)
			$CanvasLayer/AspectRatioContainer/ProgressBar.value = progress[0] * 100
		
		ResourceLoader.THREAD_LOAD_LOADED:
			print("scene loaded, instantiating...")
			scene_loaded = true  # set immediately to block any re-entry
			set_process(false)
			
			var packed_scene = ResourceLoader.load_threaded_get(Global.new_scene_path)
			var game_instance = packed_scene.instantiate()
			game_instance.connect("generation_finished", Callable(self, "_on_generation_done"))
			get_tree().root.add_child(game_instance)
			get_tree().current_scene = game_instance
			game_instance.start_world_generation()
			print("start_world_generation called")
		
		ResourceLoader.THREAD_LOAD_FAILED:
			print("Failed to load scene.")

func _on_generation_done():
	print("generation_done signal received")
	var game_scene = get_tree().current_scene
	print("got game_scene: ", game_scene)
	game_scene.thread.wait_to_finish()
	print("thread finished")
	game_scene.draw_run()
	print("draw_run done")
	queue_free()
