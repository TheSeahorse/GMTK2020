extends Node2D

onready var Player = preload("res://Game/Player/Player.tscn")
onready var Level = preload("res://Game/Level/Level.tscn")

var player
var player_jumps = 0

func _ready() -> void:
	set_process_input(true)
	randomize()
	player = Player.instance()
	var level = Level.instance()
	add_child(player)
	player.position.y = 540
	player.connect("level_cleared", self, "level_cleared")
	add_child(level)
	level.start_level("One")

func _physics_process(delta):
	if player.is_on_floor() and player.velocity.y > 0:
		player_jumps = 2
	if Input.is_action_pressed("move_left"):
		player.move(player.Direction.LEFT)
	if Input.is_action_pressed("move_right"):
		player.move(player.Direction.RIGHT)
	if not(Input.is_action_pressed("move_left")) and not(Input.is_action_pressed("move_right")):
		player.stop()

func _input(event):
	if event.is_action_pressed("jump_dash"):
		print(player_jumps)
		if player_jumps > 0:
			if randi() % 2 == 0:
				player.jump()
			else:
				player.dash()
			player_jumps -= 1

func level_cleared():
	get_tree().change_scene("res://Game/Level/Levels/Finish.tscn")
