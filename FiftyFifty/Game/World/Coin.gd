extends Area2D
class_name Coin

var value = "bronze"
var pickup_time
var pickup = false

func _process(delta: float) -> void:
	if pickup:
		if pickup_time + 250 < OS.get_ticks_msec():
			self.queue_free()


func change_value(new_value: String):
	value = new_value
	$AnimatedSprite.play(new_value)


func _on_Coin_area_entered(area: Area2D) -> void:
	if area.get_parent().collision_layer == 1:
		print("inner side")
		pickup_time = OS.get_ticks_msec()
		pickup = true
		$coin_pickup.play()
		$AnimatedSprite.play("none")
