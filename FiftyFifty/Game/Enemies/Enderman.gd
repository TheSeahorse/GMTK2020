extends KinematicBody2D
class_name Enderman

onready var EnemyLazer = preload("res://Game/Player/EnemyLazer.tscn")

enum Direction {
	RIGHT,
	LEFT,
}

var GRAVITY = 1500
var MAX_GRAVITY = 600
var MOVE_SPEED = 50
var JUMP_SPEED = -350

var velocity = Vector2.ZERO
var move_change = OS.get_ticks_msec()
var action_timer = OS.get_ticks_msec()
export var direction = Direction.LEFT

func _physics_process(delta: float) -> void:
	if action_timer + 1500 < OS.get_ticks_msec():
		action_timer = OS.get_ticks_msec()
		if randi() % 2 == 0:
			jump()
		else:
			shoot_lazer()

	if not(is_on_floor()):
		velocity.y += GRAVITY * delta
	if is_on_floor() and velocity.y > 0:
		velocity.y = 1
	if velocity.y > MAX_GRAVITY:
		velocity.y = MAX_GRAVITY

	velocity.x = calculate_direction()

	if is_on_wall():
		if direction == Direction.LEFT:
			direction = Direction.RIGHT
		else:
			direction = Direction.LEFT
		velocity *= -1
		move_change = OS.get_ticks_msec()

	if direction == Direction.LEFT:
		$Sprite.flip_h = false
	else:
		$Sprite.flip_h = true

	move_and_slide(velocity, Vector2.UP)

func calculate_direction():
	if (move_change + 5000) > OS.get_ticks_msec(): # ändrar riktning per 5000 millisec
		if direction == Direction.LEFT:
			return -MOVE_SPEED
		else:
			return MOVE_SPEED
	else:
		move_change = OS.get_ticks_msec()
		if direction == Direction.LEFT:
			direction = Direction.RIGHT
			return MOVE_SPEED
		else:
			direction = Direction.LEFT
			return -MOVE_SPEED


func shoot_lazer():
	$laser_sound.play()
	var lazer = EnemyLazer.instance()
	add_child(lazer)
	if direction == Direction.LEFT:
		lazer.position.x = -32
	else:
		lazer.position.x = 16
	lazer.position.y = -10
	lazer.init(direction)
	lazer.connect("hit", self, "on_Lazer_hit")

func on_Lazer_hit(lazer, body):
	if body is Player:
		body.hurt(-34)
	lazer.queue_free()

func jump():
	velocity.y = JUMP_SPEED
