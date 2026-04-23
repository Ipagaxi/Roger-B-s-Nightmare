extends Node2D

const tileset_file_name = Global.TILESET_FILE_NAME
@onready var tileset = preload("res://assets/Tilesets/" + tileset_file_name)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func draw():
	$TileMapLayer.tile_set = tileset
