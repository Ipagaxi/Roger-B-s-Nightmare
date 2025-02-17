extends Node2D

@onready var map_foreground = $map/Background

func _ready():
	GlobalTileBase.current_chunk = self
	
