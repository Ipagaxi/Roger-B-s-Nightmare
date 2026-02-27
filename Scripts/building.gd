extends Node2D

var building_premises_63x63 = preload("res://Map/Buildings/63x63/building_premises.tmx")

var building_insts: Array

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

	
func generate():
	var building_premises_inst = building_premises_63x63.instantiate()
	building_insts.append(building_premises_inst)
	
	
func draw():
	pass
