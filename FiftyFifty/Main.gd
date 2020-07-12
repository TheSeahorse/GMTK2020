extends CenterContainer

onready var Game = preload("res://Game/Game.tscn")

var game
var running = false

func _on_StartGameButton_pressed():
	game = Game.instance()
	add_child(game)
	running = true
	$StartGameButton.hide()

func _input(event: InputEvent) -> void:
	if not running:
		if event.is_action_pressed("enter"):
			_on_StartGameButton_pressed()
