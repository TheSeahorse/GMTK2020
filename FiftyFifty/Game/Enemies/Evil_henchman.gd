extends KinematicBody2D

enum Direction {
	RIGHT,
	LEFT,
}

var GRAVITY = 1500
var MAX_GRAVITY = 600
var MOVE_SPEED = 100

var velocity = Vector2.ZERO
var move_change = OS.get_ticks_msec()
export var direction = Direction.LEFT

func _physics_process(delta: float) -> void:
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
	if (move_change + 3000) > OS.get_ticks_msec(): # ändrar riktning per 3000 millisec
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
