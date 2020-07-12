extends KinematicBody2D

signal hit(teleport, body)

var SPEED = Vector2(10, 0)
var LIFETIME = 1400
var start_time = OS.get_ticks_msec()


func _ready():
	start_time = OS.get_ticks_msec()

func init(direction):
	if direction != 0:
		SPEED *= -1

func _physics_process(_delta):
	var collision_info = move_and_collide(SPEED)
	if collision_info and collision_info.collider:
		if OS.get_ticks_msec() - start_time > 60:
			emit_signal("hit", self, collision_info.collider)
		queue_free()

	if OS.get_ticks_msec() - start_time > LIFETIME:
		queue_free()
