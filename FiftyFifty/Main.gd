extends CenterContainer


func _on_StartGameButton_pressed():
	get_tree().change_scene("res://Game/Game.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump_dash") or event.is_action_pressed("ui_select"):
		_on_StartGameButton_pressed()
