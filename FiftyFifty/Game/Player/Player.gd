extends KinematicBody2D

class_name Player

signal level_cleared
signal take_damage
signal coin_pickup(value)

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
var prio_anim = false
var prio_anim_end = OS.get_ticks_msec()
var is_dashing = false
var is_knocked_back = false #knock back anim after taking damage
var is_hurting = false #blinking hurt animation, should not take damage during this
var dead = false
var death_start


func _process(_delta: float) -> void:
	if $Sprite.flip_h:
		$Sprite/GunOverlay.flip_h = true
		$Sprite/ThrusterOverlay.flip_h = true
	else:
		$Sprite/GunOverlay.flip_h = false
		$Sprite/ThrusterOverlay.flip_h = false
	if is_hurting:
		if hurt_start + 1000 < OS.get_ticks_msec():
			is_hurting = false
	if prio_anim:
		if prio_anim_end < OS.get_ticks_msec(): # lägg till hur länge där animationen sker
			prio_anim = false

func _physics_process(delta):
	if dead:
		return
	if is_on_ceiling():
		velocity.y = 0
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
	if is_knocked_back or dead:
		#cant jump while hurting
		return
	$Sprite.play("jump")
	$Sprite.frame = 0
	prio_anim = true
	prio_anim_end = OS.get_ticks_msec() + 500
	$jump_sound.play()
	velocity.y = JUMP_SPEED

func dash():
	if is_knocked_back or dead:
		#cant dash while hurting
		return
	is_dashing = true
	$Sprite.play("dash")
	$Sprite.frame = 0
	prio_anim = true
	prio_anim_end = OS.get_ticks_msec() + 250
	$dash_sound.play()
	if direction == Direction.RIGHT:
		dash_velocity.x = DASH_SPEED
	else:
		dash_velocity.x = -DASH_SPEED
	dash_start = OS.get_ticks_msec()

func move(move_direction):
	if is_dashing or is_knocked_back or dead:
		# Don't change direction while dashing or hurting
		return
	if not prio_anim:
		$Sprite.play("move")
	if move_direction == Direction.LEFT:
		move_velocity.x = -MOVE_SPEED
		direction = Direction.LEFT
		$Sprite.flip_h = true
	if move_direction == Direction.RIGHT:
		direction = Direction.RIGHT
		move_velocity.x = MOVE_SPEED
		$Sprite.flip_h = false

func stop():
	if is_knocked_back or dead:
		return
	if not prio_anim:
		$Sprite.play("idle")
	move_velocity.x = 0


func hurt(damage: int):
	if not is_hurting:
		emit_signal("take_damage", damage)
		prio_anim = true
		prio_anim_end = OS.get_ticks_msec() + 1000
		if not dead:
			$Sprite.play("hurt")
			$hurt_sound.play()
		hurt_start = OS.get_ticks_msec()
		is_knocked_back = true
		is_hurting = true
		velocity.y = HURT_SPEED.y
		if direction == Direction.RIGHT:
			move_velocity.x = -HURT_SPEED.x
		else:
			move_velocity.x = HURT_SPEED.x


func play_animation(node_name: String, anim_name: String):
	if dead:
		return
	get_node(node_name).play(anim_name)
	get_node(node_name).frame = 0


func play_prio_animation(name: String, msec: int):
	if dead:
		return
	$Sprite.play(name)
	$Sprite.frame = 0
	prio_anim = true
	prio_anim_end = OS.get_ticks_msec() + msec

func _on_Hurtbox_area_entered(area: Area2D) -> void:
	if area is Portal:
		emit_signal("level_cleared")
	elif area.collision_layer == 8:
		$coin_pickup.play()
		emit_signal("coin_pickup", area.value)
	elif (area != EnemyLazer): # laser damage handled in the enemy that shoots the lazer
		hurt(-25)


func die():
	if not dead:
		$death_sound.play()
		dead = true
		death_start = OS.get_ticks_msec()
		$CollisionShape2D.call_deferred("disabled", true)
		$Hurtbox/CollisionShape2D.call_deferred("disabled", true)
		$Sprite.play("death")
		$Sprite.frame = 0
