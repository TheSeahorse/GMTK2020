extends Node2D

onready var Player = preload("res://Game/Player/Player.tscn")

func _ready() -> void:
	var player = Player.instance()
	add_child(player)
