extends KinematicBody2D

signal level_cleared
signal take_damage

enum Direction {
	RIGHT,
	LEFT,
}

# Final variables
var GRAVITY = 1500
var MAX_GRAVITY = 600
var JUMP_SPEED = -650
var DASH_SPEED = 600
var MOVE_SPEED = 400

# Movement variables
var velocity = Vector2.ZERO
var move_velocity = Vector2.ZERO
var dash_velocity = Vector2.ZERO
var direction = Direction.RIGHT
var dash_start = OS.get_ticks_msec()
var dash_end = OS.get_ticks_msec()
var is_dashing = false

func _physics_process(delta):
	if not(is_on_floor()):
		velocity.y += GRAVITY * delta
	if is_on_floor() and velocity.y > 0:
		velocity.y = 1
	if velocity.y > MAX_GRAVITY:
		velocity.y = MAX_GRAVITY

	# Dash movement
	if OS.get_ticks_msec() - dash_start >= 200 and is_dashing:
		if direction == Direction.RIGHT:
			dash_velocity.x = 0
		elif direction == Direction.LEFT:
			dash_velocity.x = 0
		is_dashing = false

	velocity.x = move_velocity.x + dash_velocity.x
	move_and_slide(velocity, Vector2.UP)

func jump():
	velocity.y = JUMP_SPEED

func dash():
	is_dashing = true
	if direction == Direction.RIGHT:
		dash_velocity.x = DASH_SPEED
	else:
		dash_velocity.x = -DASH_SPEED
	dash_start = OS.get_ticks_msec()

func move(move_direction):
	if is_dashing:
		# Don't change direction while dashing
		return
	if move_direction == Direction.LEFT:
		move_velocity.x = -MOVE_SPEED
		direction = Direction.LEFT
		$Sprite.flip_h = true
	if move_direction == Direction.RIGHT:
		direction = Direction.RIGHT
		move_velocity.x = MOVE_SPEED
		$Sprite.flip_h = false

func stop():
	move_velocity.x = 0


func _on_Hurtbox_area_entered(area: Area2D) -> void:
	if area is Portal:
		emit_signal("level_cleared")
	else:
		emit_signal("take_damage", -100)
