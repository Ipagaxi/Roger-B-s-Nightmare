extends Node2D

@onready var map_foreground = $map/Background

func _ready():
	GlobalTileBase.current_chunk = self
	
	
func generate_chunk(continent_coords: Vector2i, map_coords: Vector2i):
	print("Generate Chunk")
	
func load_chunks():
	print("Load current and nearby chunks")
	#if !chunk_file_found:
	#	generate_chunk

func load_from_file(continent_coords: Vector2i, map_coords: Vector2i):
	print("Load specific chunk")
