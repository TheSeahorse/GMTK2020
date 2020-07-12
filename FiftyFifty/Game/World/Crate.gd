extends KinematicBody2D
class_name Crate

var broken = false
var break_start

func _process(delta: float) -> void:
	if broken:
		if break_start + 250 < OS.get_ticks_msec():
			self.queue_free()

func destroy():
	$AnimatedSprite.play("open")
	$crate_break.play()
	broken = true
	break_start = OS.get_ticks_msec()
