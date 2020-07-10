extends KinematicBody2D

enum Direction {
	RIGHT,
	LEFT,
}


var GRAVITY = 1500
var JUMP_SPEED = -600
var DASH_SPEED = 100
var MOVE_SPEED = 400
var velocity = Vector2.ZERO
var direction = Direction.RIGHT

func _physics_process(delta):
	velocity.y += GRAVITY * delta
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
		$Eye.rect_position.x = 5
	if move_direction == Direction.RIGHT:
		direction = Direction.RIGHT
		velocity.x = MOVE_SPEED
		$Eye.rect_position.x = 25

func stop():
	velocity.x = 0
