extends Control

onready var Global = get_node("/root/Global")

func _ready():
	$CenterContainer/VBoxContainer/ScoreLabel.text = "Score: " + str(Global.score)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("enter"):
		get_tree().change_scene("res://Main.tscn")
