extends Node2D

func _ready():
	$CanvasLayer/Control.show()
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("enter"):
		$CanvasLayer/Control.hide()
