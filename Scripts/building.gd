extends Node2D

var building_premises_63x63 = preload("res://Map/Buildings/63x63/building_premises.tmx")
var flat_1 = preload("res://Map/Buildings/63x63/flats/flat_1.tmx")
var flat_2 = preload("res://Map/Buildings/63x63/flats/flat_2.tmx")

var flats = [flat_1, flat_2]

var angles = [0, 90, 180, 270]

var building_insts: Array

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

	
func generate():
	var building_premises_inst = building_premises_63x63.instantiate()
	building_insts.append(building_premises_inst)
	add_flat()
	
	
func draw():
	for building in building_insts:
		add_child(building)
		
func add_flat():
	var flat_inst = flats[randi() % flats.size()].instantiate()
	#flat_inst.rotation_degrees = angles.pick_random()
	building_insts.append(flat_inst)
	
	
