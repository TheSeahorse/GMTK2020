extends KinematicBody2D

signal level_cleared
signal take_damage

onready var Hook = preload("res://Game/Player/Hook.tscn")

enum Direction {
	RIGHT,
	LEFT,
}

# Final variables
var GRAVITY = 1500
var MAX_GRAVITY = 600
var JUMP_SPEED = -650
var HURT_SPEED = Vector2(300, -300)
var DASH_SPEED = 600
var MOVE_SPEED = 400

# Movement variables
var velocity = Vector2.ZERO
var move_velocity = Vector2.ZERO
var dash_velocity = Vector2.ZERO
var direction = Direction.RIGHT
var dash_start = OS.get_ticks_msec()
var dash_end = OS.get_ticks_msec()
var hurt_start
var is_dashing = false
var is_knocked_back = false #knock back anim after taking damage
var is_hurting = false #blinking hurt animation, should not take damage during this

# Hook variables
var hook

func _process(delta: float) -> void:
	if is_hurting:
		if hurt_start + 1000 < OS.get_ticks_msec():
			is_hurting = false
			$Sprite.play("normal")

func _physics_process(delta):
	if not(is_on_floor()):
		velocity.y += GRAVITY * delta
	if is_on_floor() and velocity.y > 0:
		is_knocked_back = false
		velocity.y = 1
	if velocity.y > MAX_GRAVITY:
		velocity.y = MAX_GRAVITY

	# Dash movement
	if (OS.get_ticks_msec() - dash_start >= 200 and is_dashing) or is_knocked_back:
		if direction == Direction.RIGHT:
			dash_velocity.x = 0
		elif direction == Direction.LEFT:
			dash_velocity.x = 0
		is_dashing = false

	velocity.x = move_velocity.x + dash_velocity.x
	move_and_slide(velocity, Vector2.UP)

func jump():
	if is_knocked_back:
		#cant jump while hurting
		return
	velocity.y = JUMP_SPEED

func dash():
	if is_knocked_back:
		#cant dash while hurting
		return
	is_dashing = true
	if direction == Direction.RIGHT:
		dash_velocity.x = DASH_SPEED
	else:
		dash_velocity.x = -DASH_SPEED
	dash_start = OS.get_ticks_msec()

func move(move_direction):
	if is_dashing or is_knocked_back:
		# Don't change direction while dashing or hurting
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
	if is_knocked_back:
		return
	move_velocity.x = 0

func hook():
	if is_knocked_back:
		return
	print("hook")
	hook = Hook.instance()
	add_child(hook)
	hook.position.x = $Sprite.texture.get_width() / 2 + 8
	hook.position.y = $Sprite.texture.get_height() / 2 - 16


func hurt():
	hurt_start = OS.get_ticks_msec()
	is_knocked_back = true
	is_hurting = true
	velocity.y = HURT_SPEED.y
	if direction == Direction.RIGHT:
		move_velocity.x = -HURT_SPEED.x
	else:
		move_velocity.x = HURT_SPEED.x


func _on_Hurtbox_area_entered(area: Area2D) -> void:
	if area is Portal:
		emit_signal("level_cleared")
	else:
		if not is_hurting:
			emit_signal("take_damage", -25)
			$Sprite.play("hurt")
			hurt()
