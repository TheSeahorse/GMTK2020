extends Node2D

func start_level(name:String):
	var level = load("res://Game/Level/Levels/" + name + ".tscn").instance()
	add_child(level)
