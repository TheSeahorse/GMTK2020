extends Node2D

onready var Player = preload("res://Game/Player/Player.tscn")
onready var Lazer = preload("res://Game/Player/Lazer.tscn")
onready var Level = preload("res://Game/Level/Level.tscn")

var player
var player_jumps = 0
var health = 100
var lazer

func _ready() -> void:
	set_process_input(true)
	randomize()
	player = Player.instance()
	var level = Level.instance()
	add_child(player)
	player.position.y = 540
	player.connect("level_cleared", self, "level_cleared")
	player.connect("take_damage", self, "change_health")
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
		if player_jumps > 0:
			if randi() % 2 == 0:
				player.jump()
			else:
				player.dash()
			player_jumps -= 1

	if event.is_action_pressed("hook_shoot"):
		shoot()

func change_health(value: int):
	health += value
	if health > 100:
		health = 100
	elif health < 1:
		player_died()

func shoot():
	lazer = Lazer.instance()
	add_child(lazer)
	lazer.init(player.direction)
	var lazer_position_diff
	if player.direction == player.Direction.RIGHT:
		lazer_position_diff = Vector2(32, 32)
	else:
		lazer_position_diff = Vector2(-16, 32)
	lazer.position = player.position + lazer_position_diff
	lazer.connect("hit", self, "on_Lazer_hit")

func on_Lazer_hit(lazer, body):
	if body is Enemy:
		body.queue_free()
	lazer.queue_free()

func player_died():
	get_tree().change_scene("res://Main.tscn")

func level_cleared():
	get_tree().change_scene("res://Game/Level/Levels/Finish.tscn")
