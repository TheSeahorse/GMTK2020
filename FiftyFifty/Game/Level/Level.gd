extends Node2D

func start_level(name:String):
	var level = load("res://Game/Level/Levels/" + name + ".tscn").instance()
	$savage_robot.play()
	add_child(level)
