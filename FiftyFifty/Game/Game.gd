extends Node2D

onready var Player = preload("res://Game/Player/Player.tscn")
onready var Level = preload("res://Game/Level/Level.tscn")

func _ready() -> void:
	var player = Player.instance()
	var level = Level.instance()
	add_child(player)
	player.position.y = 540
	add_child(level)
	level.start_level("One")
