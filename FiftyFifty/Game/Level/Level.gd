extends Node2D

func start_level(name:String):
	print("Hej")
	var level = load("res://Game/Level/Levels/" + name + ".tscn").instance()
	add_child(level)
