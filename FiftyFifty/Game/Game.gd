extends Node2D

onready var Player = preload("res://Game/Player/Player.tscn")
onready var Lazer = preload("res://Game/Player/Lazer.tscn")
onready var Teleport = preload("res://Game/Player/Teleport.tscn")
onready var Level = preload("res://Game/Level/Level.tscn")

var player
var level
var player_jumps = 0
var health = 100
var lazer
var levels = ["One", "Two"]
var current_level
var jump_dash # 0 if jump is next, 1 if dash is next
var lazer_teleport # 0 if lazer is next, 1 if tele is next

var gun_energy = 100
var gun_shoot_start_time = OS.get_ticks_msec()

func _ready() -> void:
	set_process_input(true)
	set_process(true)
	randomize()
	start_level("One")

func _process(_delta):
	$HUD/GunBar.value = gun_energy
	if gun_energy <= 100:
		var energy_since_shot = (OS.get_ticks_msec() - gun_shoot_start_time) / 400
		gun_energy += energy_since_shot
	if gun_energy > 100:
		gun_energy = 100

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
			if jump_dash == 0:
				player.jump()
			else:
				player.dash()
			jump_dash = randi() % 2
			print("next_jump_dash: " + str(jump_dash))
			player_jumps -= 1

	if event.is_action_pressed("hook_shoot"):
		shoot()

func start_level(level_name: String):
	current_level = level_name
	health = 100
	$HUD/HealthBar.value = 100
	$HUD/GunBar.value = 100
	jump_dash = randi() % 2
	lazer_teleport = randi() % 2
	print("jump_dash: " + str(jump_dash))
	print("lazer_teleport: " + str(lazer_teleport))
	player = Player.instance()
	level = Level.instance()
	add_child(player)
	player.position.y = 540
	player.connect("level_cleared", self, "level_cleared")
	player.connect("take_damage", self, "change_health")
	add_child(level)
	level.start_level(level_name)

func change_health(value: int):
	health += value
	$HUD/HealthBar.value = health
	if health > 100:
		health = 100
	elif health < 1:
		player_died()

func shoot():
	if player.is_knocked_back:
		return

	if gun_energy >= 50:
		gun_energy -= 50
	else:
		return

	gun_shoot_start_time = OS.get_ticks_msec()

	if lazer_teleport == 0:
		player.play_prio_animation("lazer")
		$laser_sound.play()
		lazer = Lazer.instance()
		add_child(lazer)
		lazer.init(player.direction)
		var position_diff
		if player.direction == player.Direction.RIGHT:
			position_diff = Vector2(32, 32)
		else:
			position_diff = Vector2(-16, 32)
		lazer.position = player.position + position_diff
		lazer.connect("hit", self, "on_Lazer_hit")
	else:
		player.play_prio_animation("teleport")
		$teleport_sound_start.play()
		var teleport = Teleport.instance()
		var position_diff
		if player.direction == player.Direction.RIGHT:
			position_diff = Vector2(32, 32)
		else:
			position_diff = Vector2(-16, 32)
		teleport.position = player.position + position_diff
		add_child(teleport)
		teleport.init(player.direction)
		teleport.connect("hit", self, "on_Teleport_hit")
	lazer_teleport = randi() % 2
	print("next_lazer_teleport: " + str(lazer_teleport))

func on_Teleport_hit(teleport, body):
	$teleport_sound_end.play()
	var test_move = true
	var x = 0
	var y = 0
	var y_inc = -1
	var transform = teleport.get_transform()
	transform.origin = transform.origin + Vector2(-10, -32)
	while test_move:
		test_move = player.test_move(transform, Vector2(x, y))
		x -= 1
		if x <= -32:
			y += y_inc
			x = 0
		if y <= -32:
			y_inc = 1
		if y >= 32:
			break
	player.position = transform.origin + Vector2(x, y)

func on_Lazer_hit(lazer, body):
	if body is Enemy or (body is Enderman):
		body.queue_free()
	lazer.queue_free()

func player_died():
	level.queue_free()
	player.queue_free()
	start_level(current_level)

func level_cleared():
	player.queue_free()
	var new_level
	var level_index = levels.find(level.level_name)
	if level_index >= 0:
		if level_index + 1 < levels.size():
			print(level_index + 1)
			print(levels.size())
			print("level_index + 1 < levels.size()")
			new_level = levels[level_index + 1]
			level.queue_free()
			start_level(new_level)
		else:
			get_tree().change_scene("res://Game/Level/Levels/Finish.tscn")
