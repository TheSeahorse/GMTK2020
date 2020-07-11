extends Node2D

var level_name

func start_level(name: String):
	level_name = name
	var level = load("res://Game/Level/Levels/" + name + ".tscn").instance()
	$savage_robot.play()
	add_child(level)
