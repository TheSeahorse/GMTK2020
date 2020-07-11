extends KinematicBody2D

signal hit(teleport, body)

var SPEED = Vector2(10, 0)
var LIFETIME = 1400
var AMOUNT = 200
var start_time = OS.get_ticks_msec()


func _ready():
	start_time = OS.get_ticks_msec()

func init(direction):
	if direction != 0:
		SPEED *= -1

func _physics_process(delta):
	var collision_info = move_and_collide(SPEED)
	if collision_info and collision_info.collider:
		emit_signal("hit", self, collision_info.collider)
		queue_free()
	var new_lifetime = (OS.get_ticks_msec() - start_time) / 1000.0
	$Particles2D.amount = AMOUNT
	if new_lifetime > 0:
		$Particles2D.preprocess = 1

	if OS.get_ticks_msec() - start_time > LIFETIME:
		queue_free()
