extends KinematicBody2D

enum Direction {
	RIGHT,
	LEFT,
}


var GRAVITY = 1500
var MAX_GRAVITY = 600
var JUMP_SPEED = -600
var DASH_SPEED = 100
var MOVE_SPEED = 400
var velocity = Vector2.ZERO
var direction = Direction.RIGHT

func _physics_process(delta):
	if not(is_on_floor()):
		velocity.y += GRAVITY * delta
	if is_on_floor() and velocity.y > 0:
		velocity.y = 0
	if velocity.y > MAX_GRAVITY:
		velocity.y = MAX_GRAVITY
	move_and_slide(velocity, Vector2.UP)
	print(direction)

func jump():
	velocity.y = JUMP_SPEED
	
func dash():
	if direction == Direction.RIGHT:
		position.x += DASH_SPEED
	else:
		position.x -= DASH_SPEED

func move(move_direction):
	if move_direction == Direction.LEFT:
		velocity.x = -MOVE_SPEED
		direction = Direction.LEFT
		$Sprite.flip_h = true
	if move_direction == Direction.RIGHT:
		direction = Direction.RIGHT
		velocity.x = MOVE_SPEED
		$Sprite.flip_h = false

func stop():
	velocity.x = 0
