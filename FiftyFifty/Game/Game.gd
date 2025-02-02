extends Node2D

onready var Player = preload("res://Game/Player/Player.tscn")
onready var Lazer = preload("res://Game/Player/Lazer.tscn")
onready var Teleport = preload("res://Game/Player/Teleport.tscn")
onready var Level = preload("res://Game/Level/Level.tscn")
onready var Coin = preload("res://Game/World/Coin.tscn")

onready var Global = get_node("/root/Global")

var player
var level
var player_jumps = 0
var health = 100
var levels = ["One", "Two", "Three", "Four", "Five", "Six"]
var current_level
var jump_dash # 0 if jump is next, 1 if dash is next
var jd_grace = 0 # how many times the same jump/dash was gotten in a row
var lazer_teleport # 0 if lazer is next, 1 if tele is next
var lt_grace = 0 # how many times the same lazer/teleport was gotten in a row

var gun_energy = 100
var gun_shoot_start_time = OS.get_ticks_msec()

var death_screen_visible = false

# Progression variables
var weapons_activated = false
var thrusters_activated = false
var hud_activated = false

func _ready() -> void:
	Global.score = 0
	set_process_input(true)
	set_process(true)
	randomize()
	for child in $HUD.get_children():
		child.hide()
	start_level("One")

func _process(_delta):
	$HUD/GunBar.value = gun_energy
	if gun_energy <= 100:
		var energy_since_shot = (OS.get_ticks_msec() - gun_shoot_start_time) / 400
		gun_energy += energy_since_shot
	if gun_energy > 100:
		gun_energy = 100
	if thrusters_activated:
		if jump_dash == 0:
			$HUD/JumpDashButton.play("jump")
			player.play_animation("Sprite/ThrusterOverlay", "jump")
		else:
			$HUD/JumpDashButton.play("dash")
			player.play_animation("Sprite/ThrusterOverlay", "dash")
	if weapons_activated:
		if lazer_teleport == 0:
			$HUD/LazerTeleportButton.play("lazer")
			player.play_animation("Sprite/GunOverlay", "lazer")
		else:
			$HUD/LazerTeleportButton.play("teleport")
			player.play_animation("Sprite/GunOverlay", "teleport")

	$HUD/ScoreLabel.text = "Score: %s" % Global.score

func _physics_process(_delta):
	if player:
		if player.is_on_floor() and player.velocity.y > 0:
			player_jumps = 2
		if Input.is_action_pressed("move_left"):
			player.move(player.Direction.LEFT)
		if Input.is_action_pressed("move_right"):
			player.move(player.Direction.RIGHT)
		if not(Input.is_action_pressed("move_left")) and not(Input.is_action_pressed("move_right")):
			player.stop()

		if player.position.y > 2000:
			player_died()


func _input(event):
	if player:
		if thrusters_activated and event.is_action_pressed("jump_dash"):
			if player_jumps > 0:
				if jump_dash == 0:
					player.jump()
				else:
					player.dash()
				new_fifty_fifty_action("jump_dash")
				player_jumps -= 1

		if weapons_activated and event.is_action_pressed("lazer_teleport"):
			shoot()

	if death_screen_visible:
		if event.is_action_pressed("enter"):
			start_level(current_level)
			death_screen_visible = false
			$DeathScreen/Control.hide()


func start_level(level_name: String):
	if is_instance_valid(level):
		level.queue_free()
	if is_instance_valid(player):
		player.queue_free()
	current_level = level_name
	health = 100
	$HUD/HealthBar.value = 100
	$HUD/GunBar.value = 100
	jump_dash = randi() % 2
	jd_grace = 1
	lazer_teleport = randi() % 2
	lt_grace = 1
	player = Player.instance()
	level = Level.instance()
	add_child(player)
	player.position.y = 540
	player.connect("level_cleared", self, "level_cleared")
	player.connect("take_damage", self, "change_health")
	player.connect("coin_pickup", self, "coin_pickup")
	add_child(level)
	level.start_level(level_name)

	if level_name == "Two":
		$HUD/ScoreLabel.show()
		weapons_activated = true
		thrusters_activated = true

	if level_name == "Three":
		for child in $HUD.get_children():
			child.show()

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
		player.play_prio_animation("lazer", 250)
		$laser_sound.play()
		var lazer = Lazer.instance()
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
		player.play_prio_animation("teleport", 250)
		$teleport_sound_start.play()
		var teleport = Teleport.instance()
		var position_diff
		if player.direction == player.Direction.RIGHT:
			position_diff = Vector2(48, 32)
		else:
			position_diff = Vector2(-16, 32)
		teleport.position = player.position + position_diff
		add_child(teleport)
		teleport.init(player.direction)
		teleport.connect("hit", self, "on_Teleport_hit")
	new_fifty_fifty_action("lazer_teleport")


func new_fifty_fifty_action(action_name: String):
	var rand = randi() % 2
	if action_name == "jump_dash":
		if rand == jump_dash:
			if jd_grace > 3:
				if jump_dash == 1:
					jump_dash = 0
					jd_grace = 1
				else:
					jump_dash = 1
					jd_grace = 1
			else:
				jd_grace += 1
		else:
			jump_dash = rand
			jd_grace = 1
	elif action_name == "lazer_teleport":
		if rand == lazer_teleport:
			if lt_grace > 3:
				if lazer_teleport == 1:
					lazer_teleport = 0
					lt_grace = 1
				else:
					lazer_teleport = 1
					lt_grace = 1
			else:
				lt_grace += 1
		else:
			lazer_teleport = rand
			lt_grace = 1


func on_Teleport_hit(teleport, _body):
	if not is_instance_valid(player):
		return
	$teleport_sound_end.play()
	var test_move = true
	var x = 0
	var y = 0
	var y_inc = -1
	var x_inc = -1
	var transform = teleport.get_transform()
	if player.direction == player.Direction.RIGHT:
		transform.origin = transform.origin + Vector2(-10, -32)
	else:
		transform.origin = transform.origin + Vector2(-10, -32)
	while test_move:
		test_move = player.test_move(transform, Vector2(x, y))
		x += x_inc
		if x <= -8:
			x = 0
			x_inc = 1
		if x >= 8:
			y += y_inc
			x = 0
			x_inc = -1
		if y <= -8:
			y_inc = 1
			y = 0
		if y >= 8:
			break

	player.position = transform.origin + Vector2(x, y)

func on_Lazer_hit(lazer, body):
	if body is Enemy or (body is Enderman):
		if body is Enemy:
			Global.score += 100
		if body is Enderman:
			Global.score += 200
		body.queue_free()
	if body is Crate:
		call_deferred("create_coin", body.position)
		body.destroy()
	lazer.queue_free()

func create_coin(position: Vector2):
	var coin = Coin.instance()
	add_child(coin)
	coin.position.x = position.x
	coin.position.y = position.y + 8
	var rand = randi() % 10
	if rand < 2:
		coin.change_value("gold")
	elif rand < 5:
		coin.change_value("silver")
	else:
		coin.change_value("bronze")

func coin_pickup(value: String):
	if value == "bronze":
		Global.score += 100
	if value == "silver":
		Global.score += 250
	if value == "gold":
		Global.score += 500

func player_died():
	$Camera2D.position = player.get_node("Camera2D").get_camera_position()
	$Camera2D.offset = player.get_node("Camera2D").offset
	player.get_node("Camera2D").current = false
	$Camera2D.make_current()
	player.die()
	Global.score /= 2
	$DeathScreen/Control.show()
	death_screen_visible = true

func level_cleared():
	player.queue_free()
	var new_level
	var level_index = levels.find(level.level_name)
	if level_index >= 0:
		if level_index + 1 < levels.size():
			new_level = levels[level_index + 1]
			level.queue_free()
			call_deferred('start_level', new_level)
		else:
			get_tree().change_scene("res://Game/Level/Levels/Finish.tscn")
