extends Node2D

var building_premises_63x63 = preload("res://Map/Buildings/63x63/building_premises.tmx")
var room_10x20 = preload("res://Map/Buildings/63x63/rooms/room_10x20.tmx")
var room_27x11 = preload("res://Map/Buildings/63x63/rooms/room_27x11.tmx")
var room = preload("res://Map/Buildings/63x63/rooms/room_22x20.tmx")

var building_insts: Array

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

	
func generate():
	var building_premises_inst = building_premises_63x63.instantiate()
	building_insts.append(building_premises_inst)
	
	
func draw():
	for building in building_insts:
		add_child(building)
