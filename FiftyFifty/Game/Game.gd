extends Node2D

onready var Player = preload("res://Game/Player/Player.tscn")
onready var Level = preload("res://Game/Level/Level.tscn")

var player

func _ready() -> void:
	set_process_input(true)
	randomize()
	player = Player.instance()
	var level = Level.instance()
	add_child(player)
	player.position.y = 540
	add_child(level)
	level.start_level("One")
	
func _input(event):
	if event.is_action_pressed("jump_dash") and player.is_on_floor():
		if randi() % 2 == 0:
			player.jump()
		else:
			player.dash()
		
	if event.is_action_pressed("move_left"):
		player.move(player.Direction.LEFT)
	if event.is_action_pressed("move_right"):
		player.move(player.Direction.RIGHT)
	
	if event.is_action_released("move_right") and player.velocity.x > 0:
		player.stop()
	if event.is_action_released("move_left") and player.velocity.x < 0:
		player.stop()

