extends CenterContainer

onready var Game = preload("res://Game/Game.tscn")

var game
var running = false
var credits_visible = false

func _ready():
	$Credits.hide()

func _input(event: InputEvent) -> void:
	if not running:
		if event.is_action_pressed("enter"):
			if not credits_visible:
				start_game()
		if event.is_action_pressed("credits"):
			if not credits_visible:
				$Credits.show()
				$VBoxContainer.hide()
				credits_visible = true
			else:
				credits_visible = false
				$Credits.hide()
				$VBoxContainer.show()

func start_game():
	game = Game.instance()
	add_child(game)
	running = true
	$VBoxContainer.hide()
	$Credits.hide()
