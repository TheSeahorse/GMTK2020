extends Control

func _on_Button_pressed() -> void:
	get_tree().change_scene("res://Main.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump_dash") or event.is_action_pressed("ui_select"):
		_on_Button_pressed()
