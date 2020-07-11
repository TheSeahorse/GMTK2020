extends KinematicBody2D
class_name Lazer

signal hit(lazer, body)

var SPEED = Vector2(20, 0)

func init(direction):
	if direction != 0:
		SPEED *= -1
		$Sprite.flip_h = true

func _physics_process(delta):
	move_and_collide(SPEED)

func _on_Area2D_body_entered(body):
	emit_signal("hit", self, body)
